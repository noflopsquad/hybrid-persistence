class PeopleStateRepo
  def initialize(mongo)
    @mongo = mongo
  end

  def update person, time
    archive(person, time)
    persist(person)
  end

  def remove person, time
    archive(person, time)
  end

  def read first_name, last_name
    collection.find(
      first_name: first_name,
      last_name: last_name,
      current: true
    ).first
  end

  def persist person
    state = extract_person(person)
    collection.insert_one(state.merge(current: true))
  end

  def find_by fields
    people_fields = fields.select {|field| includes_field?(field)}
    retrieve_by(people_fields)
  end

  def read_archived first_name, last_name
    collection.find(
      first_name: first_name,
      last_name: last_name,
      current: false
    )
  end

  def includes_field? field
    PEOPLE_FIELDS.include?(field)
  end

  private

  def archive person, archivation_time
    persisted_state = read(person.first_name, person.last_name)
    collection.find_one_and_update(
      { first_name: person.first_name,
        last_name: person.last_name,
        current: true
        },
      persisted_state.merge(current: false, archivation_time: archivation_time)
    )
  end

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
