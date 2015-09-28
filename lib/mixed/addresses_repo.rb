require './lib/mixed/address_identity'

class AddressesRepo
  def initialize(sql, mongo)
    @sql = sql
    @mongo = mongo
  end

  def insert address, person_identity
    persist_identity(address, person_identity)
    persist_state(address)
  end

  def read person_identity
    addresses_descriptors = retrieve_descriptors(person_identity)
    build_addresses(addresses_descriptors)
  end

  def update address, person_identity
    if address_exists?(address, person_identity)
      update_state(address)
    else
      insert(address, person_identity)
    end
  end

  def delete address
    remove_state(address)
    remove_identity(address)
  end

  def find_by fields
    address_fields = fields.select {|field| ADDRESSES_FIELDS.include?(field)}
    found_addresses = retrieve_by_addresses(address_fields)
  end

  private
  ADDRESSES_FIELDS = [:city, :country]

  def collection
    @mongo[:address_states]
  end

  def retrieve_by_addresses addresses_fields
    return [] if addresses_fields.empty?
    descriptors = collection.find(addresses_fields)
    descriptors.map do |descriptor|
      Address.create_from_descriptor(descriptor)
    end
  end

  def update_state address
    state = address.variable_states.merge(
      street_name: address.street_name,
      street_address: address.street_address
    )
    collection.find_one_and_update(
      {street_name: address.street_name,
       street_address: address.street_address},
      state
    )
  end

  def address_exists? address, person_identity
    addresses = read(person_identity)
    addresses.include?(address)
  end

  def remove_identity address
    command = """
      DELETE FROM mixed_addresses WHERE street_name=?, street_address=?
      """
    data = [address.street_name, address.street_address]
    @sql.execute(command, data)
  end

  def remove_state address
    address_identity = AddressIdentity.new(address.street_name, address.street_address).hash
    collection.find_one_and_delete({street_name: address.street_name,
                                    street_address: address.street_address})
  end

  def build_addresses descriptors
    descriptors.map do |descriptor|
      build_address(descriptor)
    end
  end

  def build_address descriptor
    state = collection.find(street_name: descriptor["street_name"],
                            street_address: descriptor["street_address"]).first

    Address.create_from_descriptor(state)
  end

  def retrieve_descriptors person_identity
    query = """
      SELECT street_name, street_address FROM mixed_addresses WHERE person_id=?
      """
    @sql.execute(query, person_identity)
  end

  def persist_identity address, person_identity
    command = """
      INSERT INTO mixed_addresses (street_name, street_address, person_id)
      VALUES (?, ?, ?)
      """
    data = [
      address.street_name,
      address.street_address,
      person_identity
    ]
    @sql.execute(command, data)
  end

  def persist_state address
    state = address.variable_states.merge(street_name: address.street_name,
                                          street_address: address.street_address)
    collection.insert_one(state)
  end
end
