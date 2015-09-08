require 'faker'

class PersonFactory
	def self.fake_it
		person = Person.new(Faker::Name.first_name, Faker::Name.last_name)
		person.email = Faker::Internet.email
		person.phone = Faker::PhoneNumber.phone_number
		person.credit_card = Faker::Business.credit_card_number
		person.title = Faker::Name.title

		1..5.times do
			address = Address.new Faker::Address.street_name, Faker::Address.street_address
			address.city = Faker::Address.city
			person.add_address(address)
		end
	
		person
	end
end
