require 'forwardable'
require './lib/mixed/people_repo'
require './lib/mixed/addresses_repo'
require './lib/mixed/people_addresses_relationship'
require './lib/mixed/address_identity'
require 'set'

class MixedRepo
  def initialize
    @sql = Connections.sql
    @mongo = Connections.mongo
    @people = PeopleRepo.new(@sql, @mongo)
    @addresses = AddressesRepo.new(@sql, @mongo)
    @people_addresses_repo = PeopleAddressesRelationship.new(@sql)
  end

  def insert person
    accessible = AccessiblePerson.new(person)
    @people.insert(accessible)
    insert_addresses(accessible)
  end

  def read first_name, last_name
    person = retrieve_person(first_name, last_name)
    add_addresses_to_people([person])
    person
  end

  def update person
    accessible = AccessiblePerson.new(person)
    update_time = Time.now
    @people.update(accessible, update_time)
    update_adresses(accessible, update_time)
  end

  def delete person
    return unless exists?(person)
    remove(person)
  end

  def find_by fields
    found_people = retrieve_people_by(fields)
    add_addresses_to_people(found_people)
    found_people
  end

  def read_archived first_name, last_name
    archived_people = @people.read_archived(first_name, last_name)
    archived_people.map do |person_descriptor|
      Person.create_from(person_descriptor)
    end
    # add_addresses_to_people([person])
    # person
  end

  private
  def remove person
    accessible = AccessiblePerson.new(person)
    delete_time = Time.now
    @people.delete(accessible, delete_time)
    delete_addresses(accessible, delete_time)
  end

  def retrieve_person first_name, last_name
    person = @people.read(first_name, last_name)
    raise NotFound.new if person.nil?
    person
  end

  def exists? person
    accessible = AccessiblePerson.new(person)
    persisted = @people.read(accessible.first_name, accessible.last_name)
    not persisted.nil?
  end

  def check_existence! first_name, last_name
    raise NotFound.new unless exists?(first_name, last_name)
  end

  def retrieve_people_by fields
    found_in_people = retrieve_people(fields)
    found_in_addresses = retrieve_addresses_by(fields)
    mix(found_in_people, found_in_addresses)
  end

  def mix found_in_people, found_in_addresses
    return found_in_people.to_a if found_in_addresses.empty?
    return found_in_addresses.to_a if found_in_people.empty?
    found_in_people.intersection(found_in_addresses).to_a
  end

  def retrieve_people fields
    found_people = @people.find_by(fields)
    Set.new(found_people)
  end

  def retrieve_addresses_by fields
    found_addresses = @addresses.find_by(fields)
    found_people = retrieve_people_associated_to(found_addresses)
    Set.new(found_people)
  end

  def retrieve_people_associated_to addresses
    addresses.map do |address|
      retrieve_person_associated_to(address)
    end
  end

  def retrieve_person_associated_to address
    accessible = AccessibleAddress.new(address)
    person_identity = @people_addresses_repo.retrieve_person_associated_to(accessible)
    @people.read(person_identity.first_name, person_identity.last_name)
  end

  def delete_addresses person, delete_time
    person.addresses.each do |address|
      accessible = AccessibleAddress.new(address)
      @addresses.delete(address, delete_time)
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

  def update_adresses person, update_time
    person.addresses.each do |address|
      accessible = AccessibleAddress.new(address)
      @addresses.update(accessible, person.identity, update_time)
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
