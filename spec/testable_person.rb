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

  def changing fields
    fields.each do |field|
      key = field[0]
      value = field[1]

      if :adding_address == key
        self.add_address(value)
      else
        method_name = key.to_s + "="
        self.send(method_name.to_sym, value)
      end
    end
    self
  end

  private
  def self.define_readers_and_writers
    variable_state_fields.each do |state|
      define_method(state) { return @person.variable_states[state] }
      writer = state.to_s + "="
      define_method(writer) do |value|
        @person.variable_states[state] = value
      end
    end
  end
  define_readers_and_writers()
end
