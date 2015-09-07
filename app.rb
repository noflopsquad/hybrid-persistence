require 'sinatra/base'
require 'mongo'
require 'sqlite3'
require 'json'
require 'faker'
require './lib/person'
require './lib/address'
require './lib/repo'
require './lib/person_factory'

class App < Sinatra::Base

	before do
		@people = Repo.new
	end

	get '/create' do
		person = PersonFactory.fake_it
		result = @people.insert(person)
		halt 500 unless result == 1
	end
end
