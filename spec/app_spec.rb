require 'spec_helper'

shared_examples_for "a repo" do
  let(:repo) { described_class.new }
  let(:first_name) { "Kylie" }
  let(:last_name) { "Minogue" }
  let(:a_person) { Person.new(first_name, last_name) } 

  it "holds people sent" do
    a_person.add_address(PersonFactory.fake_address)

    repo.insert(a_person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved).to eql(a_person)
  end

  it "holds people without addresses" do
    repo.insert(a_person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved).to eql(a_person)
  end

  describe "holds people with variable states" do
    it "email" do
      email = "email@example.com"
      a_person.email = email

      repo.insert(a_person)
      retrieved = repo.read(first_name, last_name)

      expect(retrieved.email).to eql(email)
    end

    it "phone" do
      phone = "888777333666"
      a_person.phone = phone

      repo.insert(a_person)
      retrieved = repo.read(first_name, last_name)

      expect(retrieved.phone).to eql(phone)
    end

    it "credit card" do
      card = "12309823049823"
      a_person.credit_card = card

      repo.insert(a_person)
      retrieved = repo.read(first_name, last_name)

      expect(retrieved.credit_card).to eql(card)
    end

    it "title" do
      title = "Mrs."
      a_person.title = title

      repo.insert(a_person)
      retrieved = repo.read(first_name, last_name)

      expect(retrieved.title).to eql(title)
    end
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
