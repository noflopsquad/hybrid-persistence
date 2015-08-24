require 'sinatra/base'
require 'mongo'
require 'sqlite3'
require 'json'

class App < Sinatra::Base

	before do
		@mongo = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'polyglot')
		@sql = SQLite3::Database.new "sqlite.db"
	end

	get '/' do
		content_type :json
		{ hola: 'hola' }.to_json
	end
end
