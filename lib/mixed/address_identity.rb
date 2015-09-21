require 'value_object'
require 'digest/sha1'

class AddressIdentity
  extend ValueObject
  fields :street_name, :street_address
end
