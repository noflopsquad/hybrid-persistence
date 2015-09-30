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

    expect(testable_person(retrieved)).to have_attributes(
      email: email, phone: phone, credit_card: credit_card,
      title: title, nickname: nickname
    )
  end

  it "persists people addresses" do
    person.add_address(a_random_address)
    person.add_address(address)

    repo.insert(person)
    retrieved = repo.read(first_name, last_name)

    testable_person = testable_person(retrieved)
    expect(testable_person.has_address?(street_name, street_address)).to be_truthy
    expect(testable_person.has_address?("Avenida", "Valencia")).to be_falsy
    testable_address = testable_person.retrieve_address(street_name, street_address)
    expect(testable_address).to have_attributes(city: city, country: country)
  end

  describe "updating" do
    it "updates people" do
      repo.insert(person)
      updated_card = "50252067239763"
      updated_title = "Mrs"
      updated_phone = "111122223333"
      updated_email = "adios@hola.com"
      updated_nickname = "trikitrok"

      person.changing(phone: updated_phone, title: updated_title,
                      credit_card: updated_card, email: updated_email,
                      nickname: updated_nickname)
      repo.update(person)

      retrieved = repo.read(first_name, last_name)
      expect(testable_person(retrieved)).to have_attributes(
        email: updated_email, phone: updated_phone, credit_card: updated_card,
        title: updated_title, nickname: updated_nickname
      )
    end

    it "archives pre-update data of people" do
      repo.insert(person)

      person.changing(
        phone: "111122223333", title: "Mrs",
        credit_card: "50252067239763", email: "adios@hola.com",
        nickname: "trikitrok"
      )
      repo.update(person)

      archived_versions = repo.read_archived(first_name, last_name)

      expect(archived_versions.size).to eq(1)
      expect(testable_person(archived_versions.first)).to have_attributes(
        email: email, phone: phone, credit_card: credit_card,
        title: title, nickname: nickname
      )
    end

    it "changes existing address" do
      person.add_address(a_random_address)
      person.add_address(address)
      repo.insert(person)
      updated_city = "Valencia"
      updated_country = "Catalonia"

      address.changing(city: updated_city, country: updated_country)
      repo.update(person)

      retrieved = repo.read(first_name, last_name)
      testable_address = testable_person(retrieved).retrieve_address(street_name, street_address)
      expect(testable_address).to have_attributes(
        city: updated_city, country: updated_country
      )
    end

    it "archives pre-update data of address" do
      person.add_address(a_random_address)
      person.add_address(address)
      repo.insert(person)

      address.changing(city: "Valencia", country: "Catalonia")
      repo.update(person)

      archived_versions = repo.read_archived(first_name, last_name)
      archived_person = testable_person(archived_versions.first)
      testable_address = archived_person.retrieve_address(street_name, street_address)
      expect(testable_address).to have_attributes(
        city: city, country: country
      )
    end

    it "inserts non existing address" do
      repo.insert(person)
      person.add_address(address)

      repo.update(person)

      retrieved = repo.read(first_name, last_name)
      expect(testable_person(retrieved).retrieve_address(street_name, street_address)).to eq(address)
    end

    it "archives pre-update person data when a non existing address gets inserted" do
      repo.insert(person)
      person.add_address(address)

      repo.update(person)

      archived_versions = repo.read_archived(first_name, last_name)
      archived_person = testable_person(archived_versions.first)
      expect(
        archived_person.has_address?(address.street_name, address.street_address)
      ).to be false
    end
  end

  describe "deleting people" do
    it "when it already exists, it's deleted" do
      repo.insert(person)

      repo.delete(person)

      expect {repo.read(first_name, last_name)}.to raise_error(NotFound)
    end

    it "archives pre-delete person data" do
      repo.insert(person)

      repo.delete(person)

      archived_versions = repo.read_archived(first_name, last_name)
      archived_person = testable_person(archived_versions.first)
      expect(archived_person).to eq(person)
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

    it "finds something by nickname" do
      repo.insert(another_person)
      repo.insert(random_person.changing(nickname: "koko"))
      repo.insert(person)

      found = repo.find_by(nickname: "pepito")

      expect(found).to contain_exactly(another_person, person)
    end

    it "finds something by nickname and title" do
      repo.insert(another_person.changing(title: "God"))
      repo.insert(random_person.changing(nickname: "koko"))
      repo.insert(person)
      repo.insert(another_person_more.changing(title: "God"))

      found = repo.find_by(nickname: "pepito", title: "God")

      expect(found).to contain_exactly(another_person, another_person_more)
    end

    it "finds something by city" do
      another_person.add_address(a_random_address.changing(city: "Honolulu"))
      person.add_address(address)
      another_person_more.add_address(new_fake_address.changing(city: city))
      repo.insert(person)
      repo.insert(another_person)
      repo.insert(another_person_more)

      found = repo.find_by(city: city)

      expect(found).to contain_exactly(person, another_person_more)
    end

    it "finds something by city and nickname" do
      another_person.add_address(a_random_address.changing(city: "Honolulu"))
      person.add_address(address)
      another_person_more.add_address(new_fake_address.changing(city: city))
      another_person_more.changing(nickname: "yoquese")
      repo.insert(person)
      repo.insert(another_person)
      repo.insert(another_person_more)

      found = repo.find_by(city: city, nickname: "yoquese")

      expect(found).to contain_exactly(another_person_more)
    end

    it "finds nothing by city and nickname" do
      another_person.add_address(a_random_address.changing(city: "Honolulu"))
      person.add_address(address)
      another_person_more.add_address(new_fake_address.changing(city: city))
      another_person_more.changing(nickname: "yoquese")
      repo.insert(person)
      repo.insert(another_person)
      repo.insert(another_person_more)

      found = repo.find_by(city: "Lisboa", nickname: "yoquese")

      expect(found).to be_empty
    end
  end
end

describe NoSqlRepo do
  it_behaves_like "a repo"
end

describe SqlRepo do
  it_behaves_like "a repo"
end

describe HybridRepo do
  it_behaves_like "a repo"
end

def an_address
  AddressBuilder.new
end

def a_person
  PersonBuilder.new
end

def testable_person(person)
  TestablePerson.new(person)
end

def new_fake_address
  PersonFactory.fake_address()
end
