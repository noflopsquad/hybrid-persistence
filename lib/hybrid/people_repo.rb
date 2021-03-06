require './lib/hybrid/people_identity_repo'
require './lib/hybrid/people_state_repo'

class PeopleRepo
  def initialize(sql, mongo)
    @identity_repo = PeopleIdentityRepo.new(sql)
    @state_repo = PeopleStateRepo.new(mongo)
  end

  def insert person
    @identity_repo.persist(person)
    @state_repo.persist(person)
  end

  def read person_identity
    descriptor = @state_repo.read(person_identity)
    to_person(descriptor) unless descriptor.nil?
  end

  def update person, time
    @state_repo.update(person, time)
  end

  def delete person, time
    @state_repo.remove(person, time)
  end

  def find_by fields
    descriptors = @state_repo.find_by(fields)
    to_people(descriptors)
  end

  def read_archived person_identity
    @state_repo.read_archived(person_identity)
  end

  def includes_field? field
    @state_repo.includes_field?(field)
  end

  private
  def to_person descriptor
    Person.create_from(descriptor)
  end

  def to_people descriptors
    descriptors.map do |descriptor|
      to_person(descriptor)
    end
  end
end
