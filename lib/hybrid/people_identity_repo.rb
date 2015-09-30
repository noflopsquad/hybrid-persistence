class PeopleIdentityRepo
  def initialize(sql)
    @sql = sql
  end

  def exists? first_name, last_name
    query = """
      SELECT COUNT(*) FROM hybrid_people WHERE first_name = ? AND last_name = ?
      """
    records = @sql.execute(query, [first_name, last_name])
    records[0][0] != 0
  end

  def persist person
    command = """
      INSERT INTO hybrid_people (id, first_name, last_name) VALUES (?, ?, ?)
      """
    data = [person.id, person.first_name, person.last_name]
    @sql.execute(command, data)
  end
end
