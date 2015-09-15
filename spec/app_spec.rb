require 'spec_helper'

shared_examples_for "a repo" do
  let(:repo) { described_class.new }
  let(:first_name) { "Kylie" }
  let(:last_name) { "Minogue" }
  
  it "holds the persons sent" do
    a_person = Person.new(first_name, last_name)
    a_person.add_address(PersonFactory.fake_address)

    repo.insert(a_person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved).to eql(a_person)
  end
  it "hold persons with just addresses" do
    a_person = Person.new(first_name, last_name)

    repo.insert(a_person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved).to eql(a_person)
  end
end

describe MongoRepo do
  it_behaves_like "a repo"
end

describe SqlRepo do
  it_behaves_like "a repo"
end

describe MixedRepo do
  it_behaves_like "a repo"
end
