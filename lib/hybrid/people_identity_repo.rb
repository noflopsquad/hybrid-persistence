class PeopleIdentityRepo
  def initialize(sql)
    @sql = sql
  end

  def persist person
    command = """
      INSERT INTO hybrid_people (id) VALUES (?)
      """
    data = [person.id]
    @sql.execute(command, data)
  end
end
