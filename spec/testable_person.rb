class TestablePerson < Person
  extend Forwardable

  def_delegators :@person, :first_name, :last_name, :add_address, :variable_states

  def initialize(person)
    @person = person
  end

  def has_address? street_name, street_address
    @person.variable_states[:addresses].include?(Address.new(street_name, street_address))
  end

  def retrieve_address street_name, street_address
    address = @person.variable_states[:addresses].find do |address|
      address.eql?(Address.new(street_name, street_address))
    end
    TestableAddress.new(address)
  end

  [:email, :phone, :credit_card, :title, :nickname].each do |state|
    define_method(state) { return @person.variable_states[state] }
    writer = state.to_s + "="
    define_method(writer) do |value|
      @person.variable_states[state] = value
    end
  end
end
