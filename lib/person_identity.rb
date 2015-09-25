require 'value_object'

class PersonIdentity
  extend ValueObject
  fields :first_name, :last_name
end
