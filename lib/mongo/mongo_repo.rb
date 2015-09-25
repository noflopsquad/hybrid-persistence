require './lib/connections'
require './lib/person'
require './lib/address'
require './lib/not_found'

class MongoRepo
  def initialize
    @mongo = Connections.mongo
  end

  def insert person
    serializable = SerializablePerson.new(person)
    @mongo[:people].insert_one(serializable.to_h)
  end

  def read first_name, last_name
    person_descriptor = retrieve_person(first_name, last_name)
    build_person(person_descriptor)
  end

  def update person
    serializable_person = SerializablePerson.new(person)
    person_hash = serializable_person.to_h
    @mongo[:people].find_one_and_update(
      { first_name: person_hash[:first_name],
        last_name: person_hash[:last_name]
        }, person_hash)
  end

  def delete person
    serializable_person = SerializablePerson.new(person)
    person_hash = serializable_person.to_h
    @mongo[:people].find_one_and_delete(
      {
        first_name: person_hash[:first_name],
        last_name: person_hash[:last_name]
      }
    )
  end

  def find_by fields
    person_descriptors = @mongo[:people].find(compose_query_hash(fields))
    person_descriptors.map do |person_descriptor|
      build_person(person_descriptor)
    end
  end

  private

  def compose_query_hash fields
    fields.inject({}) do |query_hash_so_far, field|
      key = field[0]
      value = field[1]
      if person_field?(key)
        query_hash_so_far[key] = value
      elsif addresses_field?(key)
        query_hash_so_far["addresses." + key.to_s] = value
      end
      query_hash_so_far
    end
  end

  def person_field? field
    [:first_name, :last_name, :email, :title,
     :nickname, :phone, :credit_card].include?(field)
  end

  def addresses_field? field
    [:street_name, :street_address, :city, :country].include?(field)
  end

  def build_person person_descriptor
    person = to_person(person_descriptor)
    addresses = build_addresses(person_descriptor)
    add_addresses(person, addresses)
    person
  end

  def add_addresses person, addresses
    addresses.each do |address|
      person.add_address(address)
    end
  end

  def build_addresses descriptor
    descriptor[:addresses].map do |address_descriptor|
      Address.create_from_descriptor(address_descriptor)
    end
  end

  def retrieve_person first_name, last_name
    person = @mongo[:people].find(first_name: first_name, last_name: last_name).first
    raise NotFound.new if person.nil?
    person
  end

  def to_person descriptor
    Person.create_from_descriptor(descriptor)
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
