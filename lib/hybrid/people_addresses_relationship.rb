class PeopleAddressesRelationship
  def initialize(sql)
    @sql = sql
  end

  def retrieve_person_associated_to address
    query = """
      SELECT p.first_name, p.last_name FROM hybrid_people AS p INNER JOIN hybrid_addresses AS a
      ON p.id = a.person_id
      where a.street_name = ? AND a.street_address = ?
      """
    where = [address.street_name, address.street_address]
    @sql.execute(query, where).first
  end
end
