require 'sqlite3'
require 'mongo'

class Connections
  ENV['RACK_ENV'] = ENV['RACK_ENV'] || 'development'
  @@sql = SQLite3::Database.new("sqlite_#{ENV['RACK_ENV']}.db")
  @@sql.results_as_hash = true

  Mongo::Logger.logger.level = Logger::ERROR
  @@mongo = Mongo::Client.new([ '127.0.0.1:27017' ], :database => "hybrid_#{ENV['RACK_ENV']}")

  def self.sql
    @@sql
  end

  def self.mongo
    @@mongo
  end
end
