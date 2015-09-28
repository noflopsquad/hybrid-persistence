require './lib/connections'
require './lib/person'
require './lib/address'
require './lib/not_found'
require './lib/no_sql/people_mongo'

class NoSqlRepo
  def initialize
    @no_sql = PeopleMongo.new
  end

  def insert person
    serializable = SerializablePerson.new(person)
    @no_sql.insert(serializable)
  end

  def read first_name, last_name
    person_descriptor = retrieve_person(first_name, last_name)
    build_person(person_descriptor)
  end

  def update person
    serializable = SerializablePerson.new(person)
    @no_sql.update(serializable)
  end

  def delete person
    serializable = SerializablePerson.new(person)
    @no_sql.delete(serializable)
  end

  def find_by fields
    person_descriptors = @no_sql.find_by(fields, PEOPLE_FIELDS, ADDRESSES_FIELDS)
    person_descriptors.map do |person_descriptor|
      build_person(person_descriptor)
    end
  end

  private

  PEOPLE_FIELDS = [:email, :phone, :credit_card, :title, :nickname]
  ADDRESSES_FIELDS = [:city, :country]

  def build_person person_descriptor
    person = Person.create_from(person_descriptor)
    addresses = build_addresses(person_descriptor)
    add_addresses(person, addresses)
    person
  end

  def add_addresses person, addresses
    addresses.each do |address|
      person.add_address(address)
    end
  end

  def build_addresses person_descriptor
    person_descriptor[:addresses].map do |address_descriptor|
      Address.create_from(address_descriptor)
    end
  end

  def retrieve_person first_name, last_name
    person_descriptor = @no_sql.retrieve_person(first_name, last_name)
    raise NotFound.new if person_descriptor.nil?
    person_descriptor
  end

  class SerializablePerson < Person
    def initialize(person)
      @person = person
    end

    def to_h
      result = {
        first_name: @person.first_name,
        last_name: @person.last_name
      }

      result.merge!(@person.variable_states)
      result[:addresses] = serialize_addresses
      result
    end

    private

    def serialize_addresses
      return [] if @person.variable_states[:addresses].nil?
      @person.variable_states[:addresses].map do |address|
        SerializableAddress.new(address).to_h
      end
    end
  end

  class SerializableAddress < Address
    def initialize(address)
      @address = address
    end

    def to_h
      result = {
        street_name: @address.street_name,
        street_address: @address.street_address,
      }

      result.merge!(@address.variable_states)
      result
    end
  end
end
