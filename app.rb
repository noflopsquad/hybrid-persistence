require 'sinatra/base'
require 'json'
require './lib/person'
require './lib/address'
require './lib/mongo_repo'
require './lib/mixed_repo'
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
