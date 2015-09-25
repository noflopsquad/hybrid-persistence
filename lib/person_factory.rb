require 'faker'
require './lib/person'
require './lib/address'
require './spec/testable_person'
require './spec/testable_address'

class PersonFactory
  def self.fake_it
    person = TestablePerson.new(
      Person.new(Faker::Name.first_name, Faker::Name.last_name)
    )
    person.email = Faker::Internet.email
    person.phone = Faker::PhoneNumber.phone_number
    person.credit_card = Faker::Business.credit_card_number
    person.title = Faker::Name.title
    person.nickname = Faker::Name.first_name

    1..5.times do
      person.add_address(fake_address())
    end

    person
  end

  def self.fake_address
    address = TestableAddress.new(
      Address.new Faker::Address.street_name, Faker::Address.street_address
    )
    address.city = Faker::Address.city
    address.country = Faker::Address.country
    address
  end
end
