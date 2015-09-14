require './lib/mixed/people_repo'
require './lib/mixed/addresses_repo'
require 'value_object'

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

  private
  def insert_addresses person
    person.addresses.each do |address|
      accessible = AccessibleAddress.new(address)
      @addresses.insert(accessible, person.identity)
    end
  end

  class PersonIdentity
    extend ValueObject
    fields :first_name, :last_name
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
      variable_states[:addresses]
    end
  end

  class AddressIdentity
    extend ValueObject
    fields :street_name, :street_address
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
