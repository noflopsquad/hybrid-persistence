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
    person = to_person(person_descriptor)
    person_id = extract_id(person_descriptor)
    addresses = addresses_for(person_id)
    add_addresses(person, addresses)
    person
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

  private

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
    data = [id]
    @db.execute(command, data)
  end

  def update_person person
    command = """
      UPDATE people SET phone=?, title=?, credit_card=?, email=? WHERE first_name=? AND last_name=?
      """
    data = [
      person.phone, person.title, person.credit_card,
      person.email, person.first_name, person.last_name
    ]
    @db.execute(command, data)
  end

  def update_addresses person
    id = retrieve_person_id(person)

    person.addresses.each do |address|
      ripped_address = RippedAddress.new(address)
      if address_exists?(id)
        update_address(ripped_address, id)
      else
        persist_address(ripped_address, id)
      end
    end
  end

  def update_address address, id
    command = """
        UPDATE addresses SET city=? WHERE person_id=?
        """
    data = [address.city, id]
    @db.execute(command, data)
  end

  def persist_address address, id
    command = """
      INSERT INTO addresses(street_name, street_address, city, person_id)
      VALUES (?, ?, ?, ?)
      """
    data = [
      address.street_name,
      address.street_address,
      address.city,
      id
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
    raise NotFound.new if records.empty?
    records.first["id"]
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
    person = Person.new(descriptor["first_name"], descriptor["last_name"])
    person.title = descriptor["title"]
    person.credit_card = descriptor["credit_card"]
    person.phone = descriptor["phone"]
    person.email = descriptor["email"]
    person
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
    address = Address.new(descriptor["street_name"], descriptor["street_address"])
    address.city = descriptor["city"]
    address
  end

  def persist_person(person)
    command = """
      INSERT INTO people (first_name, last_name, phone, email, title, credit_card)
      VALUES (?, ?, ?, ?, ?, ?)
      """

    data = [
      person.first_name,
      person.last_name,
      person.phone,
      person.email,
      person.title,
      person.credit_card
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

    def_delegators :@address, :street_name, :street_address, :city

    def initialize(address)
      @address = address
    end
  end

  class RippedPerson < Person
    extend Forwardable

    def_delegators :@person, :phone, :email, :title, :credit_card, :first_name, :last_name

    def initialize(person)
      @person = person
    end

    def addresses
      return [] if @person.variable_states[:addresses].nil?
      @person.variable_states[:addresses]
    end
  end
end
