require 'spec_helper'
require 'builders'
require 'testable_person'

shared_examples_for "a repo" do
  let(:repo) { described_class.new }
  let(:first_name) { "Kylie" }
  let(:last_name) { "Minogue" }
  let(:title) {"Mrs."}
  let(:phone) {"888777333666"}
  let(:email) {"email@example.com"}
  let(:credit_card) {"12309823049823"}
  let(:nickname) {"pepito"}
  let (:person) {
    a_person.with_first_name(first_name).
    with_last_name(last_name).with_email(email).
    with_phone(phone).with_title(title).
    with_credit_card(credit_card).
    with_nickname(nickname).build()
  }
  let (:a_random_address) {PersonFactory.fake_address()}
  let (:street_name) {"Calle"}
  let (:street_address) {"Diagonal"}
  let (:city) {"Barcelona"}
  let (:address) {
    an_address.with_street_name(street_name).
    with_street_address(street_address).in(city).build()
  }

  it "holds people sent" do
    person.add_address(a_random_address)

    repo.insert(person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved).to eql(person)
  end

  it "persists people properly" do
    repo.insert(person)
    retrieved = repo.read(first_name, last_name)

    testable_person = make_testable(retrieved)
    expect(testable_person.email).to eql(email)
    expect(testable_person.phone).to eql(phone)
    expect(testable_person.credit_card).to eql(credit_card)
    expect(testable_person.title).to eql(title)
    expect(testable_person.nickname).to eql(nickname)
  end

  it "persists people addresses" do
    person.add_address(a_random_address)
    person.add_address(address)

    repo.insert(person)
    retrieved = repo.read(first_name, last_name)

    testable_person = make_testable(retrieved)
    expect(testable_person.has_address?(street_name, street_address)).to be_truthy
    expect(testable_person.has_address?("Avenida", "Valencia")).to be_falsy
    expect(testable_person.retrieve_address(street_name, street_address).city).to eq(city)
  end

  describe "when update" do
    it "updates people" do
      repo.insert(person)
      updated_card = "50252067239763"
      updated_title = "Mrs"
      updated_phone = "111122223333"
      updated_email = "adios@hola.com"
      updated_nickname = "trikitrok"

      person.phone = updated_phone
      person.title = updated_title
      person.credit_card = updated_card
      person.email = updated_email
      person.nickname = updated_nickname
      repo.update(person)

      retrieved = repo.read(first_name, last_name)
      testable_person = make_testable(retrieved)
      expect(testable_person.phone).to eq(updated_phone)
      expect(testable_person.title).to eq(updated_title)
      expect(testable_person.credit_card).to eql(updated_card)
      expect(testable_person.email).to eql(updated_email)
      expect(testable_person.nickname).to eql(updated_nickname)
    end

    it "changes existing address" do
      person.add_address(a_random_address)
      person.add_address(address)
      repo.insert(person)
      updated_city = "Valencia"

      address.city = updated_city
      repo.update(person)

      retrieved = repo.read(first_name, last_name)
      testable_person = make_testable(retrieved)
      expect(testable_person.retrieve_address(street_name, street_address).city).to eq(updated_city)
    end

    it "inserts non existing address" do
      repo.insert(person)
      person.add_address(address)

      repo.update(person)

      retrieved = repo.read(first_name, last_name)
      testable_person = make_testable(retrieved)
      expect(testable_person.retrieve_address(street_name, street_address)).to eq(address)
    end
  end

  describe "deletes people" do
    it "when it already exists, it's deleted" do
      repo.insert(person)

      repo.delete(person)

      expect {repo.read(first_name, last_name)}.to raise_error(NotFound)
    end

    it "is idempotent" do
      repo.insert(person)

      repo.delete(person)

      expect {repo.delete(person)}.to_not raise_error
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

def an_address
  AddressBuilder.new
end

def a_person
  PersonBuilder.new
end

def make_testable(person)
  TestablePerson.new(person)
end
