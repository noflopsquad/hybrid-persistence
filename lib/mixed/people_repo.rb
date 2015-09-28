class PeopleRepo
  def initialize(sql, mongo)
    @sql = sql
    @mongo = mongo
  end

  def insert person
    persist_identity(person)
    persist_state(person)
  end

  def read first_name, last_name
    check_existence!(first_name, last_name)
    retrieve_person(first_name, last_name)
  end

  def update person
    update_state(person)
  end

  def delete person
    remove_state(person)
    remove_identity(person)
  end

  def find_by person_fields
    return [] if person_fields.empty?
    descriptors = collection.find(person_fields)
    descriptors.map do |descriptor|
      Person.create_from_descriptor(descriptor)
    end
  end

  private
  def collection
    @mongo[:person_states]
  end

  def update_state person
    state = extract_person_state(person)
    collection.find_one_and_update(
      {first_name: person.first_name,
       last_name: person.last_name},
      state
    )
  end

  def remove_identity person
    command = """
      DELETE FROM mixed_people WHERE first_name = ? AND last_name = ?
      """
    data = [person.first_name, person.last_name]
    @sql.execute(command, data)
  end

  def remove_state person
    collection.find_one_and_delete(
      {first_name: person.first_name,
       last_name: person.last_name}
    )
  end

  def retrieve_person first_name, last_name
    state = collection.find(
      first_name: first_name,
      last_name: last_name
    ).first
    Person.create_from_descriptor(state)
  end

  def check_existence! first_name, last_name
    query = """
      SELECT COUNT(*) FROM mixed_people WHERE first_name = ? AND last_name = ?
      """
    records = @sql.execute(query, [first_name, last_name])
    raise NotFound.new if records[0][0] == 0
  end

  def persist_identity person
    command = """
      INSERT INTO mixed_people (id, first_name, last_name) VALUES (?, ?, ?)
      """
    data = [person.identity, person.first_name, person.last_name]
    @sql.execute(command, data)
  end

  def persist_state person
    state = extract_person_state(person)
    collection.insert_one(state)
  end

  def extract_person_state person
    state = person.variable_states.merge(
      first_name: person.first_name,
      last_name: person.last_name
    )
    state.delete(:addresses)
    state
  end
end
