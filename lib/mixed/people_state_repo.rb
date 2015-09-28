class PeopleStateRepo
  def initialize(mongo)
    @mongo = mongo
  end

  def update person
    state = extract_person(person)
    collection.find_one_and_update(
      {first_name: person.first_name,
       last_name: person.last_name},
      state
    )
  end

  def remove person
    collection.find_one_and_delete(
      {first_name: person.first_name,
       last_name: person.last_name}
    )
  end

  def read first_name, last_name
    state = collection.find(
      first_name: first_name,
      last_name: last_name
    ).first
  end

  def persist person
    state = extract_person(person)
    collection.insert_one(state)
  end

  def find_by fields
    people_fields = fields.select {|field| PEOPLE_FIELDS.include?(field)}
    retrieve_by(people_fields)
  end

  private
  def retrieve_by people_fields
    return [] if people_fields.empty?
    collection.find(people_fields)
  end

  def extract_person person
    state = person.variable_states.merge(
      first_name: person.first_name,
      last_name: person.last_name
    )
    state.delete(:addresses)
    state
  end

  PEOPLE_FIELDS = [:email, :phone, :credit_card, :title, :nickname]

  def collection
    @mongo[:person_states]
  end
end
