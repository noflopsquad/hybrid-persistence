class AddressesStateRepo
  def initialize mongo
    @mongo = mongo
  end

  def update address, time
    archive(address, time)
    persist(address)
  end

  def remove address, time
    archive(address, time)
  end

  def persist address
    state = address.variable_states.merge(id: address.id,
                                          street_name: address.street_name,
                                          street_address: address.street_address,
                                          current: true)
    insert_one(state)
  end

  def find_by fields
    addresses_fields = fields.select {|field| includes_field?(field)}
    retrieve_by(addresses_fields)
  end

  def read id
    collection.find(id: id, current: true).first
  end

  def read_archived archivation_time, id
    collection.find(id: id,
                    current: false,
                    archivation_time: archivation_time).first
  end

  def includes_field? field
    ADDRESSES_FIELDS.include?(field)
  end

  private
  ADDRESSES_FIELDS = [:city, :country]

  def archive address, archivation_time
    persisted_state = read(address.id)
    collection.find_one_and_update(
      { id: address.id, current: true },
      persisted_state.merge(current: false, archivation_time: archivation_time)
    )
  end

  def collection
    @mongo[:address_states]
  end

  def retrieve_by addresses_fields
    return [] if addresses_fields.empty?
    collection.find(addresses_fields)
  end

  def insert_one descriptor
    descriptor.delete("_id")
    collection.insert_one(descriptor)
  end
end
