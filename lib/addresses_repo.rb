	require './lib/connections'

class AddressesRepo
	def initialize
		@sql = Connections.sql
		@mongo = Connections.mongo
	end

	def insert address, person
		identity = persist_identity(address, person)
		persist_state(address, identity)
		identity
	end

	private
	def persist_identity address, person
		query =<<-SQL
INSERT INTO mixed_addresses(street_name, street_address, person_id) 
VALUES (?, ?, ?)
SQL
		data = [
			address.street_name,
			address.street_address,
			person
		]

		@sql.execute(query, data)
		@sql.last_insert_row_id
	end

	def persist_state address, identity
		identified_state = address.variable_states.merge(from: identity)
		@mongo[:address_states].insert_one(identified_state)
	end
end
