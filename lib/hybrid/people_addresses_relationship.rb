class PeopleAddressesRelationship
  def initialize(sql)
    @sql = sql
  end

  def retrieve_person_associated_to address
    query = """
      SELECT p.id FROM hybrid_people AS p INNER JOIN hybrid_addresses AS a
      ON p.id = a.person_id
      where a.id = ?
      """
    where = [address.id]
    @sql.execute(query, where).first
  end
end
