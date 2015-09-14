require 'value_object'
require 'digest/sha1'

class PersonIdentity
  extend ValueObject
  fields :first_name, :last_name

  def hash
    Digest::SHA1.hexdigest(self.first_name + " " + self.last_name)
  end
end
