require 'sinatra/base'
require 'json'
require './lib/person'
require './lib/address'
require './lib/mongo_repo'
require './lib/mixed_repo'
require './lib/sql_repo'
require './lib/person_factory'
require './lib/not_found'
require 'benchmark'
require 'mongo'

class App < Sinatra::Base
	
  before do
    Mongo::Logger.logger.level = Logger::WARN
  end

	get '/create' do
		person = PersonFactory.fake_it
		result = people.insert(person)
		halt 500 unless result == 1
	end

  get '/read/:first_name/:last_name', provides: :json do
    begin
      first_name = params[:first_name]
      last_name = params[:last_name]

      result = people.read(first_name, last_name)
      result.inspect
    rescue NotFound
      "Not our people."
    end
  end

  get '/benchmark/:size' do
    size = params[:size].to_i
    persons = []
    size.times { persons << PersonFactory.fake_it }

    puts Benchmark.measure { insert_sql(persons)  }
    puts Benchmark.measure { insert_mongo(persons)  }
    puts Benchmark.measure { insert_mixed(persons)  }
  end

  def people
    @people ||= sql_repo
  end

  def insert_sql persons
    persons.each do |person|
      sql_repo.insert(person)
    end
  end

  def insert_mongo persons
    persons.each do |person|
      mongo_repo.insert(person)
    end
  end

  def insert_mixed persons
    persons.each do |person|
      mixed_repo.insert(person)
    end
  end

  def sql_repo
    @sql_repo ||= SqlRepo.new
  end

  def mongo_repo
    @mongo_repo ||= MongoRepo.new
  end

  def mixed_repo
    @mixed_repo ||= MixedRepo.new
  end
end
