require 'spec_helper'

describe "Mongo Repo" do
  it "holds the persons sent" do
    repo = MongoRepo.new
    first_name = "Kylie"
    last_name = "Minogue"
    a_person = Person.new(first_name, last_name)
    a_person.add_address(PersonFactory.fake_address)

    repo.insert(a_person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved).to eql(a_person)
  end
  it "hold persons with just addresses" do
    repo = MongoRepo.new
    first_name = "Kylie"
    last_name = "Minogue"
    a_person = Person.new(first_name, last_name)

    repo.insert(a_person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved).to eql(a_person)
  end
end

describe "Sql Repo" do
  it "holds the persons sent" do
    repo = SqlRepo.new
    first_name = "Kylie"
    last_name = "Minogue"
    a_person = Person.new(first_name, last_name)
    a_person.add_address(PersonFactory.fake_address)

    repo.insert(a_person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved).to eql(a_person)
  end
  it "hold persons with just addresses" do
    repo = SqlRepo.new
    first_name = "Kylie"
    last_name = "Minogue"
    a_person = Person.new(first_name, last_name)

    repo.insert(a_person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved).to eql(a_person)
  end
end

describe "Mixed Repo" do
  it "holds the persons sent" do
    repo = MixedRepo.new
    first_name = "Kylie"
    last_name = "Minogue"
    a_person = Person.new(first_name, last_name)
    a_person.add_address(PersonFactory.fake_address)

    repo.insert(a_person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved).to eql(a_person)
  end
  it "hold persons with just addresses" do
    repo = MixedRepo.new
    first_name = "Kylie"
    last_name = "Minogue"
    a_person = Person.new(first_name, last_name)

    repo.insert(a_person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved).to eql(a_person)
  end
end
