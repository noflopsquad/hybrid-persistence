require 'forwardable'
require './lib/mixed/people_repo'
require './lib/mixed/addresses_repo'
require './lib/mixed/person_identity'
require './lib/mixed/address_identity'
require 'set'

class MixedRepo
  def initialize
    @sql = Connections.sql
    @mongo = Connections.mongo
    @people = PeopleRepo.new(@sql, @mongo)
    @addresses = AddressesRepo.new(@sql, @mongo)
  end

  def insert person
    accessible = AccessiblePerson.new(person)
    @people.insert(accessible)
    insert_addresses(accessible)
  end

  def read first_name, last_name
    person = @people.read(first_name, last_name)
    add_addresses_to_people([person])
    person
  end

  def update person
    accessible = AccessiblePerson.new(person)
    @people.update(accessible)
    update_adresses(accessible)
  end

  def delete person
    accessible = AccessiblePerson.new(person)
    @people.delete(accessible)
    delete_addresses(accessible)
  end

  def find_by fields
    found_people = Set.new
    found_people.merge(find_by_people(fields))
    found_people.merge(find_by_addresses(fields))
    found_people.to_a
  end

  private

  def find_by_people fields
    found_people = @people.find_by(fields)
    add_addresses_to_people(found_people)
    found_people
  end

  def find_by_addresses fields
    found_addresses = @addresses.find_by(fields)
    find_people_associated_to(found_addresses)
  end

  def find_people_associated_to addresses
    addresses.map do |address|
      find_person_associated_to(AccessibleAddress.new(address))
    end
  end

  def find_person_associated_to address
    query = """
      SELECT p.first_name, p.last_name FROM mixed_people AS p INNER JOIN mixed_addresses AS a
      ON p.id = a.person_id
      where a.street_name = ? AND a.street_address = ?
      """
    where = [address.street_name, address.street_address]
    person_identity = @sql.execute(query, where).first
    @people.read(person_identity["first_name"], person_identity["last_name"])
  end

  def delete_addresses person
    person.addresses.each do |address|
      accessible = AccessibleAddress.new(address)
      @addresses.delete(address)
    end
  end

  def add_addresses_to_people people
    people.each do |person|
      accessible = AccessiblePerson.new(person)
      addresses = @addresses.read(accessible.identity)
      add_addresses(accessible, addresses)
    end
  end

  def add_addresses person, addresses
    addresses.each do |address|
      person.add_address(address)
    end
  end

  def update_adresses person
    person.addresses.each do |address|
      accessible = AccessibleAddress.new(address)
      @addresses.update(accessible, person.identity)
    end
  end

  def insert_addresses person
    person.addresses.each do |address|
      accessible = AccessibleAddress.new(address)
      @addresses.insert(accessible, person.identity)
    end
  end

  class AccessiblePerson < Person
    extend Forwardable

    def_delegators :@person, :first_name, :last_name, :variable_states, :add_address

    def initialize(person)
      @person = person
    end

    def identity
      PersonIdentity.new(first_name, last_name).hash
    end

    def addresses
      return [] if variable_states[:addresses].nil?
      variable_states[:addresses]
    end
  end

  class AccessibleAddress < Address
    extend Forwardable

    def_delegators :@address, :street_name, :street_address, :variable_states

    def initialize address
      @address = address
    end

    def identity
      AddressIdentity.new(street_name, street_address).hash
    end
  end
end
