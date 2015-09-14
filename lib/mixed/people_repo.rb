require './lib/connections'

class PeopleRepo
	def initialize
		@sql = Connections.sql
		@mongo = Connections.mongo
	end

	def insert person
		persist_identity(person)
		persist_state(person)
	end

	private
	def persist_identity person
		data = [person.first_name, person.last_name]
		query = <<-SQL
INSERT INTO mixed_people (first_name, last_name) VALUES (?, ?)
SQL
		@sql.execute(query, data)
	end

	def persist_state person
		identified_state = person.variable_states.merge(from: person.identity)
		identified_state.delete(:addresses)
		@mongo[:person_states].insert_one(identified_state)
	end
end
