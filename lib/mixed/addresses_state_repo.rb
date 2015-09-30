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
    state = address.variable_states.merge(street_name: address.street_name,
                                          street_address: address.street_address,
                                          current: true)
    collection.insert_one(state)
  end

  def find_by fields
    addresses_fields = fields.select {|field| ADDRESSES_FIELDS.include?(field)}
    retrieve_by(addresses_fields)
  end

  def read street_name, street_address
    collection.find(street_name: street_name,
                    street_address: street_address,
                    current: true).first
  end

  private
  ADDRESSES_FIELDS = [:city, :country]

  def archive address, archivation_time
    persisted_state = read(address.street_name, address.street_address)
    collection.find_one_and_update(
      { street_name: address.street_name,
        street_address: address.street_address,
        current: true
        },
      persisted_state.merge(current: false, archivation_time: archivation_time.to_i)
    )
  end

  def collection
    @mongo[:address_states]
  end

  def retrieve_by addresses_fields
    return [] if addresses_fields.empty?
    collection.find(addresses_fields)
  end
end
