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
  let (:country) {"Spain"}
  let (:address) {
    an_address.with_street_name(street_name).
    with_street_address(street_address).in(city).
    with_country(country).build()
  }

  it "holds people sent" do
    person.add_address(a_random_address)

    repo.insert(person)
    retrieved = repo.read(first_name, last_name)

    expect(retrieved).to eq(person)
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
    testable_address = testable_person.retrieve_address(street_name, street_address)
    expect(testable_address.city).to eq(city)
    expect(testable_address.country).to eq(country)
  end

  describe "updating" do
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
      updated_country = "Catalonia"

      address.city = updated_city
      address.country = updated_country
      repo.update(person)

      retrieved = repo.read(first_name, last_name)
      testable_person = make_testable(retrieved)
      testable_address = testable_person.retrieve_address(street_name, street_address)
      expect(testable_address.city).to eq(updated_city)
      expect(testable_address.country).to eq(updated_country)
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

  describe "deleting people" do
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

  describe "finding several people by any field" do
    let(:random_person) { PersonFactory.fake_it() }
    let(:another_person) {
      a_person.with_first_name("Federico").
      with_last_name("Mota").with_email(email).
      with_phone(phone).with_title(title).
      with_credit_card(credit_card).
      with_nickname(nickname).build()
    }
    let(:another_person_more) {
      a_person.with_first_name("Koko").
      with_last_name("Loko").with_email(email).
      with_phone(phone).with_title(title).
      with_credit_card(credit_card).
      with_nickname(nickname).build()
    }

    it "finds by nickname" do
      random_person.nickname = "koko"
      repo.insert(another_person)
      repo.insert(random_person)
      repo.insert(person)

      found = repo.find_by({:nickname => "pepito"})

      expect(found).not_to include(random_person)
      expect(found).to include(another_person)
      expect(found).to include(person)
    end

    it "finds by nickname and title" do
      random_person.nickname = "koko"
      another_person.title = "God"
      another_person_more.title = "God"
      repo.insert(another_person)
      repo.insert(random_person)
      repo.insert(person)
      repo.insert(another_person_more)

      found = repo.find_by({:nickname => "pepito", :title => "God"})

      expect(found).not_to include(random_person)
      expect(found).not_to include(person)
      expect(found).to include(another_person)
      expect(found).to include(another_person_more)
    end

    it "finds by city" do
      a_random_address.city = "Honolulu"
      another_person.add_address(a_random_address)
      person.add_address(address)
      another_adress_more = PersonFactory.fake_address()
      another_adress_more.city = city
      another_person_more.add_address(another_adress_more)
      repo.insert(person)
      repo.insert(another_person)
      repo.insert(another_person_more)

      found = repo.find_by({:city => city})

      expect(found).to include(person)
      expect(found).not_to include(another_person)
      expect(found).to include(another_person_more)
    end

    it "finds by city and nickname" do
      a_random_address.city = "Honolulu"
      another_person.add_address(a_random_address)
      person.add_address(address)
      another_adress_more = PersonFactory.fake_address()
      another_adress_more.city = city
      another_person_more.add_address(another_adress_more)
      another_person_more.nickname = "yoquese"
      repo.insert(person)
      repo.insert(another_person)
      repo.insert(another_person_more)

      found = repo.find_by({:city => city, :nickname => "yoquese"})

      expect(found).not_to include(person)
      expect(found).not_to include(another_person)
      expect(found).to include(another_person_more)
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
