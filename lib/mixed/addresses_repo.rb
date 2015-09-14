	require './lib/connections'

class AddressesRepo
	def initialize
		@sql = Connections.sql
		@mongo = Connections.mongo
	end

	def insert address, person_identity
		persist_identity(address, person_identity)
		persist_state(address)
	end

	private
	def persist_identity address, person_identity
		query =<<-SQL
INSERT INTO mixed_addresses(street_name, street_address, person_id) 
VALUES (?, ?, ?)
SQL
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
