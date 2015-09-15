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
		person = build_person(person_descriptor)
		addresses = build_addresses(person_descriptor)
		add_addresses(person, addresses)
		person
	end

	private

	def add_addresses person, addresses
		addresses.each do |address|
			person.add_address(address)
		end		
	end

	def build_addresses descriptor
		descriptor[:addresses].map do |address_descriptor|
			address = Address.new(address_descriptor[:street_name], address_descriptor[:street_address])
			address.city = address_descriptor[:city]
			address
		end
	end

	def retrieve_person first_name, last_name
		person = @mongo[:people].find(first_name: first_name, last_name: last_name).first
		raise NotFound.new if person.nil?
		person
	end

	def build_person descriptor
		person = Person.new(descriptor[:first_name], descriptor[:last_name])
		person.email = descriptor[:email] unless descriptor[:email].nil?
		person.phone = descriptor[:phone] unless descriptor[:phone].nil?
		person.title = descriptor[:title] unless descriptor[:title].nil?
		person.credit_card = descriptor[:credit_card] unless descriptor[:credit_card].nil?
		person
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
			addresses = @person.variable_states[:addresses].map do |address| 
				SerializableAddress.new(address).to_h
			end
			result[:addresses] = addresses
			result
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
