require 'sqlite3'
require 'mongo'

class Connections
	@@sql = SQLite3::Database.new('sqlite.db')
  @@sql.results_as_hash = true
  
  @@mongo = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'mixed')

  def self.sql
    @@sql
  end

  def self.mongo
		@@mongo
	end
end