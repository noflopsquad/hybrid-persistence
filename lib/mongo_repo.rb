class MongoRepo
	def initialize
		@mongo = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'polyglot')
	end

	def insert person
		serializable = SerializablePerson.new(person)
		@mongo[:people].insert_one(serializable.to_h)
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
