class PeopleMongo
  def initialize
    @mongo = Connections.mongo
  end

  def insert person
    @mongo[:people].insert_one(person.to_h)
  end

  def update person
    person_hash = person.to_h
    @mongo[:people].find_one_and_update(
      { first_name: person_hash[:first_name],
        last_name: person_hash[:last_name]
        }, person_hash)
  end

  def delete person
    person_hash = person.to_h
    @mongo[:people].find_one_and_delete(
      {
        first_name: person_hash[:first_name],
        last_name: person_hash[:last_name]
      }
    )
  end

  def find_by fields, people_fields, addresses_fields
    query_hash = compose_query_hash(fields, people_fields, addresses_fields)
    @mongo[:people].find(query_hash)
  end

  def retrieve_person first_name, last_name
    @mongo[:people].find(first_name: first_name, last_name: last_name).first
  end

  private

  def compose_query_hash fields, people_fields, addresses_fields
    fields.inject({}) do |query_hash_so_far, field|
      key = field[0]
      value = field[1]
      if people_fields.include?(key)
        query_hash_so_far[key] = value
      elsif addresses_fields.include?(key)
        query_hash_so_far["addresses." + key.to_s] = value
      end
      query_hash_so_far
    end
  end

end
