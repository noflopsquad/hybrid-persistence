class AddressesIdentityRepo
  def initialize(sql)
    @sql = sql
  end

  def read person_identity
    query = "SELECT id FROM hybrid_addresses WHERE person_id=?"
    @sql.execute(query, person_identity)
  end

  def persist address, person
    command = "INSERT INTO hybrid_addresses (id, person_id) VALUES (?, ?)"
    data = [address.id, person.id]
    @sql.execute(command, data)
  end
end
