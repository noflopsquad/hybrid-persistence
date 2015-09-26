class Address
  def initialize street_name, street_address
    @street_name = street_name
    @street_address = street_address
    @variable_states = {}
  end

  def == other
    same_street_name = street_name == other.street_name
    same_street_address = street_address == other.street_address
    same_street_name && same_street_address
  end

  alias_method :eql?, :==

  def self.create_from_descriptor(descriptor)
    address = Address.new(descriptor["street_name"], descriptor["street_address"])
    variable_state_fields.each do |field|
      address.send(:variable_states)[field] = descriptor[field.to_s]
    end
    address
  end

  protected
  attr_reader :street_name, :street_address, :variable_states

  def self.variable_state_fields
    [:city, :country]
  end
end
