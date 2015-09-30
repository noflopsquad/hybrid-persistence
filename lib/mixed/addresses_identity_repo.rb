class AddressesIdentityRepo
  def initialize(sql)
    @sql = sql
  end

  def remove address
    command = """
      DELETE FROM mixed_addresses WHERE street_name=?, street_address=?
      """
    data = [address.street_name, address.street_address]
    @sql.execute(command, data)
  end

  def read person
    query = """
      SELECT street_name, street_address FROM mixed_addresses WHERE person_id=?
      """
    @sql.execute(query, person.identity)
  end

  def persist address, person
    command = """
      INSERT INTO mixed_addresses (street_name, street_address, person_id)
      VALUES (?, ?, ?)
      """
    data = [
      address.street_name,
      address.street_address,
      person.identity
    ]
    @sql.execute(command, data)
  end
end
