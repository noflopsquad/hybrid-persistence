require './lib/mixed/address_identity'
require './lib/mixed/addresses_identity_repo'
require './lib/mixed/addresses_state_repo'

class AddressesRepo
  def initialize sql, mongo
    @identity_repo = AddressesIdentityRepo.new(sql)
    @state_repo = AddressesStateRepo.new(mongo)
  end

  def insert address, person_identity
    @identity_repo.persist(address, person_identity)
    @state_repo.persist(address)
  end

  def read person_identity
    addresses_identities = @identity_repo.retrieve(person_identity)
    retrieve_addresses(addresses_identities)
  end

  def update address, person_identity
    if address_exists?(address, person_identity)
      @state_repo.update(address)
    else
      insert(address, person_identity)
    end
  end

  def delete address
    @state_repo.remove(address)
    @identity_repo.remove(address)
  end

  def find_by fields
    descriptors = @state_repo.find_by(fields)
    build_addresses(descriptors)
  end

  private

  def address_exists? address, person_identity
    addresses = read(person_identity)
    addresses.include?(address)
  end

  def build_addresses descriptors
    descriptors.map do |descriptor|
      Address.create_from_descriptor(descriptor)
    end
  end

  def retrieve_addresses addresses_identities
    descriptors = addresses_identities.map do |address_identity|
      @state_repo.read(address_identity["street_name"], address_identity["street_address"])
    end
    build_addresses(descriptors)
  end
end
