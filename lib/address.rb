class Address
	def initialize street_name, street_address
		@street_name = street_name
		@street_address = street_address
		@variable_states = {}
	end

	def city=(city)
		@variable_states[:city] = city
	end

	def to_h
		result = {
			street_name: @street_name,
			street_address: @street_address,
		}

		result.merge!(@variable_states)
		result
	end
end