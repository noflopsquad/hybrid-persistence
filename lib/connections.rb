require 'sqlite3'
require 'mongo'

class Connections
	p "Connections"
	@@sql = SQLite3::Database.new('sqlite.db')
	@@mongo = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'mixed')

	def self.sql
		@@sql
	end

	def self.mongo
		@@mongo
	end
end
