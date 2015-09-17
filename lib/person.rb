class Person

	def initialize(first_name, last_name)
		@first_name = first_name
		@last_name = last_name
		@variable_states = {}
	end

	[:email, :phone, :credit_card, :title].each do |state|
		define_method(state) { return @variable_states[state] }
		writer = state.to_s + "="
		define_method(writer) do |value|
		  @variable_states[state] = value
		end
	end

	def add_address address
		@variable_states[:addresses] ||= []
		@variable_states[:addresses] << address
	end

	def eql? other
		same_first = first_name.eql?(other.first_name)
		same_last = last_name.eql?(other.last_name)
		same_first && same_last
	end

	def has_address? street_name, street_address
		@variable_states[:addresses].include?(Address.new(street_name, street_address))
	end

	def retrieve_address street_name, street_address
		@variable_states[:addresses].find do |address|
			address.eql?(Address.new(street_name, street_address))
		end
	end

	protected
	attr_reader :first_name, :last_name, :variable_states
end