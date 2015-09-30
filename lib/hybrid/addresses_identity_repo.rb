class AddressesIdentityRepo
  def initialize(sql)
    @sql = sql
  end

  def read person_identity
    query = """
      SELECT street_name, street_address FROM hybrid_addresses WHERE person_id=?
      """
    @sql.execute(query, person_identity)
  end

  def persist address, person
    command = """
      INSERT INTO hybrid_addresses (street_name, street_address, person_id)
      VALUES (?, ?, ?)
      """
    data = [
      address.street_name,
      address.street_address,
      person.id
    ]
    @sql.execute(command, data)
  end
end
