require './lib/connections'
require './lib/mixed/person_identity'

class PeopleRepo
	def initialize
		@sql = Connections.sql
		@mongo = Connections.mongo
	end

	def insert person
		persist_identity(person)
		persist_state(person)
	end

	def read first_name, last_name
		check_existence!(first_name, last_name)
		retrieve_person(first_name, last_name)
	end

	private

	def retrieve_person first_name, last_name
		person = Person.new(first_name, last_name)
		person_identity = PersonIdentity.new(first_name, last_name).hash
		state = @mongo[:person_states].find(from: person_identity).first
		person.email = state[:email]
		person.phone = state[:phone]
		person.title = state[:title]
		person.credit_card = state[:credit_card]
		person
	end

	def check_existence! first_name, last_name
		query = """
			SELECT COUNT(*) FROM mixed_people WHERE first_name = ? AND last_name = ?
		"""
		records = @sql.execute(query, [first_name, last_name])
		raise NotFound.new if records[0][0] == 0
	end

	def persist_identity person
		data = [person.first_name, person.last_name]
		query = """
			INSERT INTO mixed_people (first_name, last_name) VALUES (?, ?)
		"""
		@sql.execute(query, data)
	end

	def persist_state person
		identified_state = person.variable_states.merge(from: person.identity)
		identified_state.delete(:addresses)
		@mongo[:person_states].insert_one(identified_state)
	end
end
