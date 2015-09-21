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

  it "persists people properly" do
    title = "Mrs."
    phone = "888777333666"
    email = "email@example.com"
    card = "12309823049823"
    a_person.email = email
    a_person.phone = phone
    a_person.credit_card = card
    a_person.title = title

    repo.insert(a_person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved.email).to eql(email)
    expect(retrieved.phone).to eql(phone)
    expect(retrieved.credit_card).to eql(card)
    expect(retrieved.title).to eql(title)
  end

  it "persists people addresses" do
    street_name = "Calle"
    street_address = "de la Mar"
    address = Address.new(street_name, street_address)
    city = 'Valencia'
    address.city = city
    a_person.add_address(PersonFactory.fake_address())
    a_person.add_address(address)

    repo.insert(a_person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved.has_address?(street_name, street_address)).to be_truthy
    expect(retrieved.has_address?("Francesc", "Barcelona")).to be_falsy
    expect(retrieved.retrieve_address(street_name, street_address).city).to eq(city)
  end

  describe "when update" do
    before(:each) do
      a_person.phone = '999988887777'
      a_person.title = 'Ms'
      a_person.credit_card = "569561659652395"
      a_person.email = "email@aa.com"
    end

    it "updates people" do
      repo.insert(a_person)

      updated_phone = "111122223333"
      a_person.phone = updated_phone
      updated_title = "Mrs"
      a_person.title = updated_title
      updated_card = "50252067239763"
      a_person.credit_card = updated_card
      updated_email = "adios@hola.com"
      a_person.email = updated_email

      repo.update(a_person)

      retrieved = repo.read(first_name, last_name)
      expect(retrieved.phone).to eq(updated_phone)
      expect(retrieved.title).to eq(updated_title)
      expect(retrieved.credit_card).to eql(updated_card)
      expect(retrieved.email).to eql(updated_email)
    end

    it "changes existing address" do
      a_person.add_address(PersonFactory.fake_address)
      street_name = "Calle"
      street_address = "Diagonal"
      address = Address.new(street_name, street_address)
      address.city = "Barcelona"
      a_person.add_address(address)
      repo.insert(a_person)
      updated_city = "Valencia"
      address.city = updated_city

      repo.update(a_person)

      retrieved = repo.read(first_name, last_name)
      expect(retrieved.retrieve_address(street_name, street_address).city).to eq(updated_city)
    end

    it "inserts non existing address" do
      repo.insert(a_person)
      street_name = "Calle"
      street_address = "Diagonal"
      address = Address.new(street_name, street_address)
      address.city = "Barcelona"
      a_person.add_address(address)

      repo.update(a_person)

      retrieved = repo.read(first_name, last_name)
      expect(retrieved.retrieve_address(street_name, street_address)).to eq(address)
    end
  end

  describe "deletes people" do
    it "when it already exists, it's deleted" do
      repo.insert(a_person)

      repo.delete(a_person)

      expect {repo.read(first_name, last_name)}.to raise_error(NotFound)
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
