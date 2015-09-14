class Address
	def initialize street_name, street_address
		@street_name = street_name
		@street_address = street_address
		@variable_states = {}
	end

	def city=(city)
		@variable_states[:city] = city
	end

	protected
	attr_reader :street_name, :street_address, :variable_states
end
