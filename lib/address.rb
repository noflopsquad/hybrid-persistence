class Address
	def initialize street_name, street_address
		@street_name = street_name
		@street_address = street_address
		@variable_states = {}
	end

	def city= city
		@variable_states[:city] = city
	end

	def eql? other
		same_street_name = street_name == other.street_name
		same_street_address = street_address == other.street_address
		same_street_name && same_street_address
	end

	alias_method :==, :eql?

	protected
	attr_reader :street_name, :street_address, :variable_states
end
