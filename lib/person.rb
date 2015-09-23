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

  def eql? other
    same_first = first_name.eql?(other.first_name)
    same_last = last_name.eql?(other.last_name)
    same_first && same_last
  end

  alias_method :==, :eql?

  def self.create_from_descriptor(descriptor)
    person = Person.new(descriptor["first_name"], descriptor["last_name"])
    person.send(:variable_states)[:title] = descriptor["title"]
    person.send(:variable_states)[:credit_card] = descriptor["credit_card"]
    person.send(:variable_states)[:phone] = descriptor["phone"]
    person.send(:variable_states)[:email] = descriptor["email"]
    person.send(:variable_states)[:nickname] = descriptor["nickname"]
    person
  end

  protected
  attr_reader :first_name, :last_name, :variable_states
end
