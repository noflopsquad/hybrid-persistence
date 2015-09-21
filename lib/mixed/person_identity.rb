require 'value_object'
require 'digest/sha1'

class PersonIdentity
  extend ValueObject
  fields :first_name, :last_name
end
