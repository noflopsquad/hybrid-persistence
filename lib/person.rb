require 'person_identity'

class Person

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
    @variable_states = {}
  end

  def add_address address
    @variable_states[:addresses] ||= []
    @variable_states[:addresses] << address
  end

  def == other
    same_first = first_name.eql?(other.first_name)
    same_last = last_name.eql?(other.last_name)
    same_first && same_last
  end

  alias_method :eql?, :==

  def identity
    PersonIdentity.new(first_name, last_name).hash
  end

  def hash
    identity
  end

  def self.create_from_descriptor(descriptor)
    person = Person.new(descriptor["first_name"], descriptor["last_name"])
    variable_state_fields.each do |field|
      person.send(:variable_states)[field] = descriptor[field.to_s]
    end
    person
  end

  protected
  attr_reader :first_name, :last_name, :variable_states

  def self.variable_state_fields
    [:email, :phone, :credit_card, :title, :nickname]
  end
end
