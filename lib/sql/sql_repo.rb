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
		query = """
			UPDATE people SET phone=?, title=? WHERE first_name=? AND last_name=?
		"""
		ripped_person = RippedPerson.new(person)
		data = [ripped_person.phone, ripped_person.title, ripped_person.first_name, ripped_person.last_name]
		@db.execute(query, data)
	end

	private

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
		addresses_query = """
			SELECT * FROM addresses WHERE person_id = ?		
		"""
		@db.execute(addresses_query, [person_id])
	end

	def to_address descriptor
		address = Address.new(descriptor["street_name"], descriptor["street_address"])
		address.city = descriptor["city"]
		address
	end

	def persist_person(person)
		query = """
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

		@db.execute(query, data)
	end

	def persist_addresses(addresses, person_id)
		query =<<-SQL
INSERT INTO addresses(street_name, street_address, city, person_id) 
VALUES (?, ?, ?, ?)
SQL

		addresses.each do |address|
			serializable_address = RippedAddress.new(address)
			data = [
				serializable_address.street_name,
				serializable_address.street_address,
				serializable_address.city,
				person_id
			]
			@db.execute(query, data)
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
