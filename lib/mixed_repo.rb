require './lib/people_repo'
require './lib/addresses_repo'

class MixedRepo
  def initialize
    @people = PeopleRepo.new
    @addresses = AddressesRepo.new
  end

  def insert person
    accessible = AccessiblePerson.new(person)
    identity = @people.insert(accessible)
    insert_addresses(accessible, identity)
  end

  private
  def insert_addresses person, identity
    person.addresses.each do |address|
      accessible = AccessibleAddress.new(address)
      @addresses.insert(accessible, identity)
    end
  end

  class AccessiblePerson < Person
    def initialize(person)
      @person = person
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

  class AccessibleAddress < Address
    def initialize address
      @address = address
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
