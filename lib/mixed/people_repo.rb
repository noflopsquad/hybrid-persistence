require './lib/mixed/people_identity_repo'
require './lib/mixed/people_state_repo'

class PeopleRepo
  def initialize(sql, mongo)
    @identity_repo = PeopleIdentityRepo.new(sql)
    @state_repo = PeopleStateRepo.new(mongo)
  end

  def insert person
    @identity_repo.persist(person)
    @state_repo.persist(person)
  end

  def read first_name, last_name
    check_existence!(first_name, last_name)
    descriptor = @state_repo.read(first_name, last_name)
    to_person(descriptor)
  end

  def update person
    @state_repo.update(person)
  end

  def delete person
    @state_repo.remove(person)
    @identity_repo.remove(person)
  end

  def find_by fields
    descriptors = @state_repo.find_by(fields)
    to_people(descriptors)
  end

  private

  def check_existence! first_name, last_name
    raise NotFound.new unless @identity_repo.exists?(first_name, last_name)
  end

  def to_person descriptor
    Person.create_from(descriptor)
  end

  def to_people descriptors
    descriptors.map do |descriptor|
      to_person(descriptor)
    end
  end
end
