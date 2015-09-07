class SqlRepo
	def initialize
		@db = SQLite3::Database.new('sqlite.db')
	end

	def insert(person)
		serializable_person = RippedPerson.new(person)
		addresses = serializable_person.addresses
		persist_person(serializable_person)
		person_id = @db.last_insert_row_id
		persist_addresses(addresses, person_id)
	end

	private
	def persist_person(person)
		query =<<-SQL
INSERT INTO people(first_name, last_name, phone, email, title, credit_card) 
VALUES (?, ?, ?, ?, ?, ?)
SQL

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
		def initialize(address)
			@address = address
		end

		def street_name
			@address.street_name
		end

		def street_address
			@address.street_address
		end

		def city
			@address.variable_states[:city]
		end
	end

	class RippedPerson < Person
		def initialize(person)
			@person = person
		end

		def addresses
			@person.variable_states[:addresses]
		end

		def phone
			@person.variable_states[:phone]
		end

		def email
			@person.variable_states[:email]
		end

		def title
			@person.variable_states[:title]
		end

		def credit_card
			@person.variable_states[:credit_card]
		end

		def first_name
			@person.first_name
		end

		def last_name
			@person.last_name
		end
	end
end
