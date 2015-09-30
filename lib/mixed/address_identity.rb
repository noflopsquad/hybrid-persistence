require 'value_object'

class AddressIdentity
  extend ValueObject
  fields :street_name, :street_address
end
