require 'forwardable'
require './lib/connections'
require './lib/not_found'
require './lib/person'
require './lib/address'
require './lib/sql/people_sqlite3'

class SqlRepo
  def initialize
    @sql = PeopleSqlite3.new
  end

  def insert person
    ripped_person = RippedPerson.new(person)
    addresses = ripped_person.addresses
    @sql.insert_person(ripped_person)
    person_id = @sql.last_insert
    persist_addresses(addresses, person_id)
  end

  def read first_name, last_name
    person_descriptor = @sql.read_person(first_name, last_name)
    build_person(person_descriptor)
  end

  def update person
    ripped_person = RippedPerson.new(person)
    @sql.archive_person(ripped_person.first_name, ripped_person.last_name)
    @sql.update_person(ripped_person)
    update_addresses(ripped_person)
  end

  def delete person
    ripped_person = RippedPerson.new(person)
    @sql.delete_addresses(ripped_person)
    @sql.delete_person(ripped_person)
  end

  def find_by field_values
    person_descriptors = @sql.find_people(field_values, PEOPLE_FIELDS, ADDRESSES_FIELDS)
    person_descriptors.map do |person_descriptor|
      build_person(person_descriptor)
    end
  end

  def read_archived first_name, last_name
    person_descriptors = @sql.read_archived(first_name, last_name)
    person_descriptors.map do |person_descriptor|
      build_archived_person(person_descriptor)
    end
  end

  private

  PEOPLE_FIELDS = [:email, :phone, :credit_card, :title, :nickname]
  ADDRESSES_FIELDS = [:city, :country]

  def build_archived_person person_descriptor
    Person.create_from(person_descriptor)
  end

  def build_person person_descriptor
    person = Person.create_from(person_descriptor)
    person_id = extract_id(person_descriptor)
    addresses = addresses_for(person_id)
    add_addresses(person, addresses)
    person
  end

  def update_addresses person
    id = @sql.read_person_id(person)
    person.addresses.each do |address|
      ripped_address = RippedAddress.new(address)
      @sql.update_address(ripped_address, id)
    end
  end

  def extract_id person_descriptor
    person_descriptor["id"]
  end

  def add_addresses person, addresses
    addresses.each do |address|
      person.add_address(address)
    end
  end

  def addresses_for person_id
    addresses = @sql.read_addresses_of(person_id)
    addresses.map do |address_descriptor|
      Address.create_from(address_descriptor)
    end
  end

  def persist_addresses(addresses, person_id)
    addresses.each do |address|
      ripped_address = RippedAddress.new(address)
      @sql.insert_address(ripped_address, person_id)
    end
  end

  class RippedAddress < Address
    extend Forwardable

    def_delegators :@address, :street_name, :street_address

    def initialize(address)
      @address = address
    end

    private
    def self.define_readers
      variable_state_fields.each do |state|
        define_method(state) { return @address.variable_states[state] }
      end
    end
    define_readers()
  end

  class RippedPerson < Person
    extend Forwardable

    def_delegators :@person, :first_name, :last_name

    def initialize(person)
      @person = person
    end

    def addresses
      return [] if @person.variable_states[:addresses].nil?
      @person.variable_states[:addresses]
    end

    private
    def self.define_readers
      variable_state_fields.each do |state|
        define_method(state) { return @person.variable_states[state] }
      end
    end
    define_readers()
  end
end
