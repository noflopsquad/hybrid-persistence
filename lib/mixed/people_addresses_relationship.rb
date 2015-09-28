require './lib/person_identity'

class PeopleAddressesRelationship
  def initialize(sql)
    @sql = sql
  end

  def retrieve_person_associated_to address
    query = """
      SELECT p.first_name, p.last_name FROM mixed_people AS p INNER JOIN mixed_addresses AS a
      ON p.id = a.person_id
      where a.street_name = ? AND a.street_address = ?
      """
    where = [address.street_name, address.street_address]
    result = @sql.execute(query, where).first
    PersonIdentity.new(result["first_name"], result["last_name"])
  end
end
