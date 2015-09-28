require 'forwardable'
require './lib/connections'
require './lib/not_found'
require './lib/person'
require './lib/address'

class SqlRepo
  def initialize
    @db = Connections.sql
  end

  def insert person
    ripped_person = RippedPerson.new(person)
    addresses = ripped_person.addresses
    persist_person(ripped_person)
    person_id = @db.last_insert_row_id
    persist_addresses(addresses, person_id)
  end

  def read first_name, last_name
    person_descriptor = retrieve_person(first_name, last_name)
    build_person(person_descriptor)
  end

  def update person
    ripped_person = RippedPerson.new(person)
    update_person(ripped_person)
    update_addresses(ripped_person)
  end

  def delete person
    ripped_person = RippedPerson.new(person)
    delete_addresses(ripped_person)
    delete_person(ripped_person)
  end

  def find_by field_values
    person_descriptors = find_people(field_values)
    person_descriptors.map do |person_descriptor|
      build_person(person_descriptor)
    end
  end

  private

  PEOPLE_FIELDS = [:email, :phone, :credit_card, :title, :nickname]
  ADDRESSES_FIELDS = [:city, :country]

  def find_people fields
    query = create_find_by_query(fields)
    data = fields.values
    @db.execute(query, data)
  end

  def create_find_by_query fields
    "SELECT * FROM people LEFT JOIN addresses ON people.id = addresses.person_id " +
      create_where_clause(fields.keys)
  end

  def create_where_clause field_names
    clause = "WHERE " + compose_field_name(field_names.first) + " = ?"
    field_names.drop(1).each do |field_name|
      clause += " AND " + compose_field_name(field_name) +" = ?"
    end
    clause
  end

  def compose_field_name field_name
    return "people." + field_name.to_s if PEOPLE_FIELDS.include?(field_name)
    return "addresses." + field_name.to_s if ADDRESSES_FIELDS.include?(field_name)
  end

  def build_person person_descriptor
    person = to_person(person_descriptor)

    person_id = extract_id(person_descriptor)
    addresses = addresses_for(person_id)
    add_addresses(person, addresses)
    person
  end

  def delete_person person
    id = retrieve_person_id(person)
    command = """
      DELETE FROM people WHERE id=?
      """
    data = [id]
    @db.execute(command, data)
  end

  def delete_addresses person
    id = retrieve_person_id(person)
    command = """
      DELETE FROM addresses WHERE person_id=?
      """
    where = [id]
    @db.execute(command, where)
  end

  def update_person person
    command = """
      UPDATE people SET phone=?, title=?, credit_card=?, email=?, nickname=?
      WHERE first_name=? AND last_name=?
      """
    data = [
      person.phone, person.title, person.credit_card,
      person.email, person.nickname
    ]
    where = [ person.first_name, person.last_name ]

    @db.execute(command, data + where)
  end

  def update_addresses person
    id = retrieve_person_id(person)

    person.addresses.each do |address|
      change(address, id)
    end
  end

  def change address, id
    ripped_address = RippedAddress.new(address)
    if address_exists?(id)
      update_address(ripped_address, id)
    else
      persist_address(ripped_address, id)
    end
  end

  def update_address address, id
    command = """
        UPDATE addresses SET city=?, country=? WHERE person_id=?
        """
    data = [address.city, address.country]
    where = [id]
    @db.execute(command, data + where)
  end

  def persist_address address, id
    command = """
      INSERT INTO addresses(street_name, street_address, city, person_id, country)
      VALUES (?, ?, ?, ?, ?)
      """
    data = [
      address.street_name,
      address.street_address,
      address.city,
      id,
      address.country
    ]
    @db.execute(command, data)
  end

  def address_exists? id
    query = """
      SELECT COUNT(*) FROM addresses WHERE person_id=?
      """
    data = [id]
    result = @db.execute(query, data)
    result.first[0] != 0
  end

  def retrieve_person_id person
    query = """
      SELECT id FROM people WHERE first_name=? AND last_name=?
      """
    data = [person.first_name, person.last_name]
    records = @db.execute(query, data)
    return records.first["id"] unless records.empty?
  end

  def extract_id person_descriptor
    person_descriptor["id"]
  end

  def retrieve_person first_name, last_name
    query = """
      SELECT * FROM people WHERE first_name = ? AND last_name = ?
      """
    records = @db.execute(query, [first_name, last_name])
    raise NotFound.new if records.empty?
    records.first
  end

  def to_person descriptor
    Person.create_from_descriptor(descriptor)
  end

  def add_addresses person, addresses
    addresses.each do |address|
      person.add_address(address)
    end
  end

  def addresses_for person_id
    addresses = retrieve_addresses_of(person_id)
    addresses.map do |address_descriptor|
      to_address(address_descriptor)
    end
  end

  def retrieve_addresses_of person_id
    query = """
      SELECT * FROM addresses WHERE person_id = ?
      """
    @db.execute(query, [person_id])
  end

  def to_address descriptor
    Address.create_from_descriptor(descriptor)
  end

  def persist_person(person)
    command = """
      INSERT INTO people (first_name, last_name, phone, email, title, credit_card, nickname)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      """

    data = [
      person.first_name,
      person.last_name,
      person.phone,
      person.email,
      person.title,
      person.credit_card,
      person.nickname
    ]

    @db.execute(command, data)
  end

  def persist_addresses(addresses, person_id)
    addresses.each do |address|
      ripped_address = RippedAddress.new(address)
      persist_address(ripped_address, person_id)
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
