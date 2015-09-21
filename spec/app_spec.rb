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

    let(:street_name) { "Calle" }
    let(:street_address) { "de la Mar" }
    let(:address) { Address.new(street_name, street_address) }
    it "addresses" do
      a_person.add_address(address)

      repo.insert(a_person)
      retrieved = repo.read(first_name, last_name)

      expect(retrieved.has_address?(street_name, street_address)).to be_truthy
      expect(retrieved.has_address?("Francesc", "Barcelona")).to be_falsy
    end

    it "holds addresses variable state" do
      city = 'Valencia'
      address.city = city
      a_person.add_address(PersonFactory.fake_address())
      a_person.add_address(address)

      repo.insert(a_person)
      retrieved = repo.read(first_name, last_name)

      expect(retrieved.retrieve_address(street_name, street_address).city).to eq(city)
    end
  end

  describe "updates people" do
    it "phone" do
      a_person.phone = '999988887777'
      repo.insert(a_person)
      updated_phone = "111122223333"
      a_person.phone = updated_phone

      repo.update(a_person)

      retrieved = repo.read(first_name, last_name)
      expect(retrieved.phone).to eq(updated_phone)
    end

    it "title" do
      a_person.title = 'Ms'
      repo.insert(a_person)
      updated_title = "Mrs"
      a_person.title = updated_title

      repo.update(a_person)

      retrieved = repo.read(first_name, last_name)
      expect(retrieved.title).to eq(updated_title)
    end

    it "credit card" do
      card = "12309823049823"
      a_person.credit_card = card
      repo.insert(a_person)
      updated_card = "50252067239763"
      a_person.credit_card = updated_card

      repo.update(a_person)

      retrieved = repo.read(first_name, last_name)
      expect(retrieved.credit_card).to eql(updated_card)
    end

    it "email" do
      email = "hola@hola.com"
      a_person.email = email
      repo.insert(a_person)
      updated_email = "adios@hola.com"
      a_person.email = updated_email

      repo.update(a_person)

      retrieved = repo.read(first_name, last_name)
      expect(retrieved.email).to eql(updated_email)
    end

    describe "addresses" do
      it "changing existing addresses" do
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

      it "when address doesn't exist, it's inserted" do
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
