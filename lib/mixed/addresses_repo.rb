require './lib/mixed/address_identity'
require './lib/mixed/addresses_identity_repo'
require './lib/mixed/addresses_state_repo'

class AddressesRepo
  def initialize sql, mongo
    @identity_repo = AddressesIdentityRepo.new(sql)
    @state_repo = AddressesStateRepo.new(mongo)
  end

  def insert address, person
    @identity_repo.persist(address, person)
    @state_repo.persist(address)
  end

  def read person
    addresses_identities = @identity_repo.read(person.identity)
    addresses_descriptors = retrieve(addresses_identities) do |street_name, street_address|
      @state_repo.read(street_name, street_address)
    end
    build_addresses(addresses_descriptors)
  end

  def update address, person, update_time
    if address_exists?(address, person)
      @state_repo.update(address, update_time)
    else
      insert(address, person)
    end
  end

  def delete address, delete_time
    @state_repo.remove(address, delete_time)
  end

  def find_by fields
    descriptors = @state_repo.find_by(fields)
    build_addresses(descriptors)
  end

  def archive address, archivation_time
    @state_repo.archive(address, archivation_time)
  end

  def addresses_of_person person_identity
    addresses_identities = @identity_repo.read(person_identity)
    addresses_descriptors = retrieve(addresses_identities) do |street_name, street_address|
      @state_repo.read(street_name, street_address)
    end
    build_addresses(addresses_descriptors)
  end

  def addresses_of_archived_person person_identity, archivation_time
    addresses_identities = @identity_repo.read(person_identity)
    addresses_descriptors = retrieve(addresses_identities) do |street_name, street_address|
      @state_repo.read_archived(street_name, street_address, archivation_time)
    end
    build_addresses(addresses_descriptors)
  end

  private
  def address_exists? address, person
    addresses = read(person)
    addresses.include?(address)
  end

  def build_addresses descriptors
    descriptors.map do |descriptor|
      Address.create_from(descriptor)
    end
  end

  def retrieve addresses_identities, &block
    addresses_identities.map do |address_identity|
      block.yield(
        address_identity["street_name"], address_identity["street_address"]
      )
    end.compact
  end
end
