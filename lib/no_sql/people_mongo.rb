class PeopleMongo
  def initialize
    @mongo = Connections.mongo
  end

  def insert person_descriptor
    insert_one(people_collection, person_descriptor)
  end

  def read first_name, last_name
    people_collection.find(first_name: first_name, last_name: last_name).first
  end

  def update person_descriptor
    people_collection.find_one_and_update(
      { first_name: person_descriptor[:first_name],
        last_name: person_descriptor[:last_name]
        }, person_descriptor)
  end

  def delete person_descriptor
    people_collection.find_one_and_delete(
      {
        first_name: person_descriptor[:first_name],
        last_name: person_descriptor[:last_name]
      }
    )
  end

  def find_by fields, people_fields, addresses_fields
    query_hash = compose_query_hash(fields, people_fields, addresses_fields)
    people_collection.find(query_hash)
  end

  def archive person_descriptor
    person_descriptor.merge!(archivation_time: Time.now.to_i)
    insert_one(archived_people_collection, person_descriptor)
  end

  def read_archived first_name, last_name
    archived_people_collection.find(first_name: first_name, last_name: last_name)
  end

  def person_exists? first_name, last_name
    person_descriptor = read(first_name, last_name)
    not person_descriptor.nil?
  end

  private

  def people_collection
    @mongo[:people]
  end

  def archived_people_collection
    @mongo[:archived_people]
  end

  def insert_one collection, descriptor
    descriptor.delete("_id")
    collection.insert_one(descriptor)
  end

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
