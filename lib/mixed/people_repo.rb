require './lib/mixed/people_identity_repo'

class PeopleRepo
  def initialize(sql, mongo)
    @identity_repo = PeopleIdentityRepo.new(sql)
    @mongo = mongo
  end

  def insert person
    @identity_repo.persist(person)
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
    @identity_repo.remove(person)
  end

  def find_by fields
    people_fields = fields.select {|field| PEOPLE_FIELDS.include?(field)}
    retrieve_by(people_fields)
  end

  private
  PEOPLE_FIELDS = [:email, :phone, :credit_card, :title, :nickname]

  def collection
    @mongo[:person_states]
  end

  def retrieve_by people_fields
    return [] if people_fields.empty?
    descriptors = collection.find(people_fields)
    descriptors.map do |descriptor|
      Person.create_from_descriptor(descriptor)
    end
  end

  def update_state person
    state = extract_person_state(person)
    collection.find_one_and_update(
      {first_name: person.first_name,
       last_name: person.last_name},
      state
    )
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
    raise NotFound.new unless @identity_repo.exists?(first_name, last_name)
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
