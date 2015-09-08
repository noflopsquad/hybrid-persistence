require 'sinatra/base'
require 'json'
require './lib/person'
require './lib/address'
require './lib/mongo_repo'
require './lib/mixed_repo'
require './lib/sql_repo'
require './lib/person_factory'
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


  get '/benchmark/:size' do
    size = params[:size].to_i
    people = []
    size.times { people << PersonFactory.fake_it }

    puts Benchmark.measure { insert_sql(people)  }
    puts Benchmark.measure { insert_mongo(people)  }
    puts Benchmark.measure { insert_mixed(people)  }
  end


  def insert_sql people
    people.each do |person|
      sql_repo.insert(person)
    end
  end

  def insert_mongo people
    people.each do |person|
      mongo_repo.insert(person)
    end
  end

  def insert_mixed people
    people.each do |person|
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
