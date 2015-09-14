require 'value_object'
require 'digest/sha1'

class AddressIdentity
  extend ValueObject
  fields :street_name, :street_address

  def hash
    Digest::SHA1.hexdigest(self.street_name + " " + self.street_address)
  end
end
