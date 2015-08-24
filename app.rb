require 'sinatra/base'

class App < Sinatra::Base

	get '/' do
		"It works!"
	end
end
