class Person

	def initialize(first_name, last_name)
		@first_name = first_name
		@last_name = last_name
		@variable_states = {}
	end

	def email=(email)
		@variable_states[:email] = email
	end

	def phone=(phone)
		@variable_states[:phone] = phone
	end

	def credit_card=(credit_card)
		@variable_states[:credit_card] = credit_card
	end

	def title=(title)
		@variable_states[:title] = title
	end

	def add_address(address)
		@variable_states[:addresses] ||= []
		@variable_states[:addresses] << address
	end

	protected
	attr_reader :first_name, :last_name, :variable_states
end