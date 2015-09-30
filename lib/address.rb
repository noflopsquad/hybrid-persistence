require 'address_identity'
require 'forwardable'

class Address
  extend Forwardable

  def initialize street_name, street_address
    @identity = AddressIdentity.new(street_name, street_address)
    @variable_states = {}
  end

  def == other
    identity.eql?(other.identity)
  end

  alias_method :eql?, :==

  def hash
    identity.hash
  end

  alias_method :id, :hash

  def self.create_from(descriptor)
    address = Address.new(descriptor["street_name"], descriptor["street_address"])
    variable_state_fields.each do |field|
      address.send(:variable_states)[field] = descriptor[field.to_s]
    end
    address
  end

  protected
  attr_reader :variable_states, :identity
  def_delegators :@identity, :street_name, :street_address

  def self.variable_state_fields
    [:city, :country]
  end
end
