require 'person_identity'
require 'forwardable'

class Person
  extend Forwardable

  def initialize(first_name, last_name)
    @identity = PersonIdentity.new(first_name, last_name)
    @variable_states = {}
  end

  def add_address address
    @variable_states[:addresses] ||= []
    @variable_states[:addresses] << address
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
    person = Person.new(descriptor["first_name"], descriptor["last_name"])
    variable_state_fields.each do |field|
      person.send(:variable_states)[field] = descriptor[field.to_s]
    end
    person
  end

  protected
  attr_reader :variable_states, :identity
  def_delegators :@identity, :first_name, :last_name

  def self.variable_state_fields
    [:email, :phone, :credit_card, :title, :nickname]
  end
end
