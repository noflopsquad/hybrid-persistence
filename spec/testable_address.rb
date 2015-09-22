class TestableAddress < Address
  extend Forwardable

  def_delegators :@address, :street_name, :street_address, :variable_states

  def initialize(address)
    @address = address
  end

  [:city].each do |state|
    define_method(state) { return @address.variable_states[state] }
    writer = state.to_s + "="
    define_method(writer) do |value|
      @address.variable_states[state] = value
    end
  end
end
