class PeopleSqlite3
  def initialize
    @db = Connections.sql
  end

  def insert_person person
    command = """
      INSERT INTO people (first_name, last_name, phone, email, title, credit_card, nickname)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      """
    data = [
      person.first_name,
      person.last_name,
      person.phone,
      person.email,
      person.title,
      person.credit_card,
      person.nickname
    ]
    @db.execute(command, data)
  end

  def last_insert
    @db.last_insert_row_id
  end

  def insert_address address, id
    command = """
      INSERT INTO addresses(street_name, street_address, city, person_id, country)
      VALUES (?, ?, ?, ?, ?)
      """
    data = [
      address.street_name,
      address.street_address,
      address.city,
      id,
      address.country
    ]
    @db.execute(command, data)
  end

  def find_people fields, people_fields, addresses_fields
    query_composer = FindQueryComposer.new(people_fields, addresses_fields)
    query = query_composer.create_find_by_query(fields)
    data = fields.values
    @db.execute(query, data)
  end

  def read_person first_name, last_name
    query = """
      SELECT * FROM people WHERE first_name = ? AND last_name = ?
      """
    records = @db.execute(query, [first_name, last_name])
    raise NotFound.new if records.empty?
    records.first
  end

  def update_person person
    command = """
      UPDATE people SET phone=?, title=?, credit_card=?, email=?, nickname=?
      WHERE first_name=? AND last_name=?
      """
    data = [
      person.phone, person.title, person.credit_card,
      person.email, person.nickname
    ]
    where = [ person.first_name, person.last_name ]
    @db.execute(command, data + where)
  end

  def delete_person person
    id = read_person_id(person)
    command = """
      DELETE FROM people WHERE id=?
      """
    where = [id]
    @db.execute(command, where)
  end

  def delete_addresses person
    id = read_person_id(person)
    command = """
      DELETE FROM addresses WHERE person_id=?
      """
    where = [id]
    @db.execute(command, where)
  end

  def read_addresses_of person_id
    query = """
      SELECT * FROM addresses WHERE person_id = ?
      """
    @db.execute(query, [person_id])
  end

  def read_person_id person
    query = """
      SELECT id FROM people WHERE first_name=? AND last_name=?
      """
    data = [person.first_name, person.last_name]
    records = @db.execute(query, data)
    return records.first["id"] unless records.empty?
  end

  def update_address address, id
    if address_exists?(id)
      change_address(address, id)
    else
      insert_address(address, id)
    end
  end

  private

  def change_address address, id
    command = """
      UPDATE addresses SET city=?, country=? WHERE person_id=?
      """
    data = [address.city, address.country]
    where = [id]
    @db.execute(command, data + where)
  end

  def address_exists? id
    query = """
      SELECT COUNT(*) FROM addresses WHERE person_id=?
      """
    data = [id]
    result = @db.execute(query, data)
    result.first[0] != 0
  end

  class FindQueryComposer
    def initialize(people_fields, addresses_fields)
      @people_fields = people_fields
      @addresses_fields = addresses_fields
    end

    def create_find_by_query fields
      "SELECT * FROM people LEFT JOIN addresses ON people.id = addresses.person_id " +
        create_where_clause(fields.keys)
    end

    private
    def create_where_clause field_names
      clause = "WHERE " + compose_field_name(field_names.first) + " = ?"
      field_names.drop(1).each do |field_name|
        clause += " AND " + compose_field_name(field_name) +" = ?"
      end
      clause
    end

    def compose_field_name field_name
      return "people." + field_name.to_s if @people_fields.include?(field_name)
      return "addresses." + field_name.to_s if @addresses_fields.include?(field_name)
    end
  end
end
