require 'sinatra/base'
require 'mongo'
require 'sqlite3'
require 'json'
require 'faker'
require './lib/person'
require './lib/address'
require './lib/mongo_repo'
require './lib/sql_repo'
require './lib/person_factory'

class App < Sinatra::Base

	get '/create' do
		person = PersonFactory.fake_it
		result = people.insert(person)
		halt 500 unless result == 1
	end

	def people
		@people ||= MixedRepo.new
	end
end


class MixedRepo
	def initialize
		@people = PeopleRepo.new
		@addresses = AddressesRepo.new

		@sql = SQLite3::Database.new('sqlite.db')
		@mongo = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'mixed')
	end


	def insert(person)
		identity = @people.insert(person)
		addresses = extract_addresses(person)
		@addresses.insert(addresses, identity)
	end

	private
	def persist_identity(person)
		identity = persist_person_identity(person)
		persist_addresses_identities(identity)
	end


	def persist_person_identity(person)
		data = [person.first_name, person.last_name]
		query = <<-SQL
INSERT INTO mixed_people (first_name, last_name) VALUES (?, ?)
SQL
		@sql.execute(query, data)
		@sql.last_insert_row_id
	end


	def persist_state(person, identity)
		identified_state = person.variable_states.merge(from: identity)
		addresses = identified_state.delete(:addresses)
		addresses.each do |address|
			@address_repo.insert(address)
		end 
		@mongo[:person_states].insert_one(identified_state)
	end

	class MyPerson < Person
		def initialize(person)
			@person = person
		end


		def first_name
			@person.first_name
		end

		def last_name
			@person.last_name
		end

		def variable_states
			@person.variable_states
		end
	end
end