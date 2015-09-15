require './lib/mixed/people_repo'
require './lib/mixed/addresses_repo'
require './lib/mixed/person_identity'
require './lib/mixed/address_identity'

class MixedRepo
  def initialize
    @people = PeopleRepo.new
    @addresses = AddressesRepo.new
  end

  def insert person
    accessible = AccessiblePerson.new(person)
    @people.insert(accessible)
    insert_addresses(accessible)
  end

  def read first_name, last_name
    person_identity = PersonIdentity.new(first_name, last_name).hash
    person = @people.read(first_name, last_name)
    addresses = @addresses.read(person_identity)
    add_addresses(person, addresses)
    person
  end

  private

  def add_addresses person, addresses
    addresses.each do |address|
      person.add_address(address)
    end
  end

  def insert_addresses person
    person.addresses.each do |address|
      accessible = AccessibleAddress.new(address)
      @addresses.insert(accessible, person.identity)
    end
  end

  class AccessiblePerson < Person
    def initialize(person)
      @person = person
    end

    def identity
      PersonIdentity.new(first_name, last_name).hash
    end

    def first_name
      @person.first_name
    end

    def last_name
      @person.last_name
    end

    def variable_states
      @person.variable_states
    end

    def addresses
      return [] if variable_states[:addresses].nil?
      variable_states[:addresses]
    end
  end

  class AccessibleAddress < Address
    def initialize address
      @address = address
    end

    def identity
      AddressIdentity.new(street_name, street_address).hash
    end

    def street_name
      @address.street_name
    end

    def street_address
      @address.street_address
    end

    def variable_states
      @address.variable_states
    end
  end
end
