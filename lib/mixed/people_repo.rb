require './lib/connections'
require './lib/mixed/person_identity'

class PeopleRepo
  def initialize
    @sql = Connections.sql
    @mongo = Connections.mongo
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
    remove_state(person)
    persist_state(person)
  end

  def delete person
    remove_state(person)
    remove_identity(person)
  end

  private

  def collection
    @mongo[:person_states]
  end

  def remove_identity person
    command = """
      DELETE FROM mixed_people WHERE first_name = ? AND last_name = ?
      """
    data = [person.first_name, person.last_name]
    @sql.execute(command, data)
  end

  def remove_state person
    person_identity = PersonIdentity.new(person.first_name, person.last_name).hash
    collection.find_one_and_delete({from: person_identity})
  end

  def retrieve_person first_name, last_name
    person = Person.new(first_name, last_name)
    person_identity = PersonIdentity.new(first_name, last_name).hash
    state = collection.find(from: person_identity).first
    person.email = state[:email]
    person.phone = state[:phone]
    person.title = state[:title]
    person.credit_card = state[:credit_card]
    person
  end

  def check_existence! first_name, last_name
    query = """
      SELECT COUNT(*) FROM mixed_people WHERE first_name = ? AND last_name = ?
      """
    records = @sql.execute(query, [first_name, last_name])
    raise NotFound.new if records[0][0] == 0
  end

  def persist_identity person
    data = [person.first_name, person.last_name]
    command = """
      INSERT INTO mixed_people (first_name, last_name) VALUES (?, ?)
      """
    @sql.execute(command, data)
  end

  def persist_state person
    identified_state = person.variable_states.merge(from: person.identity)
    identified_state.delete(:addresses)
    collection.insert_one(identified_state)
  end
end
