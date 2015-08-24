require 'sinatra/base'
require 'mongo'

class App < Sinatra::Base

	before do
		@db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'polyglot')
	end

	get '/' do
		@db[:test].insert_one({ name: 'Clotxinismo' })
		"It works!"
	end
end
