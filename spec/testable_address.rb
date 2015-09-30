class TestableAddress < Address
  extend Forwardable

  def_delegators :@address, :street_name, :street_address, :variable_states, :identity

  def initialize(address)
    @address = address
  end

  def changing fields
    fields.each do |field|
      key = field[0].to_s + "="
      value = field[1]
      self.send(key.to_sym, value)
    end
    self
  end

  private
  def self.define_readers_and_writers
    variable_state_fields.each do |state|
      define_method(state) { return @address.variable_states[state] }
      writer = state.to_s + "="
      define_method(writer) do |value|
        @address.variable_states[state] = value
      end
    end
  end
  define_readers_and_writers()
end
