require './lib/connections'
require './lib/mixed/address_identity'

class AddressesRepo
	def initialize
		@sql = Connections.sql
		@mongo = Connections.mongo
	end

	def insert address, person_identity
		persist_identity(address, person_identity)
		persist_state(address)
	end

	def read person_identity
		addresses_descriptors = retrieve_descriptors(person_identity)
		build_addresses(addresses_descriptors)
	end

	private

	def build_addresses descriptors
		descriptors.map do |descriptor|
			build_address(descriptor)
		end
	end

	def build_address descriptor
		address_identity = AddressIdentity.new(descriptor["street_name"], descriptor["street_address"])
		address = Address.new(address_identity.street_name, address_identity.street_address)
		state = @mongo[:address_states].find(from: address_identity.hash).first
		address.city = state[:city]
		address
	end

	def retrieve_descriptors person_identity
		query = """
			SELECT street_name, street_address FROM mixed_addresses WHERE person_id=?	
		"""

		@sql.execute(query, person_identity)
	end

	def persist_identity address, person_identity
		query = """
			INSERT INTO mixed_addresses (street_name, street_address, person_id) 
			VALUES (?, ?, ?)
		"""
		data = [
			address.street_name,
			address.street_address,
			person_identity
		]

		@sql.execute(query, data)
	end

	def persist_state address
		identified_state = address.variable_states.merge(from: address.identity)
		@mongo[:address_states].insert_one(identified_state)
	end
end
