require 'sqlite3'
require 'mongo'

ENV['RACK_ENV'] = 'test'

require 'rake'
require 'rack/test'
require File.expand_path '../../app.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() App end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  load File.expand_path("../../Rakefile", __FILE__)
  Rake::Task.define_task(:environment)

  config.before(:each) do
    clean_db()
  end

  config.after(:each) do
    clean_db()
  end
end

def clean_db
  Rake::Task["db:drop"].reenable
  Rake::Task["db:drop"].invoke
  Rake::Task["db:schema"].reenable
  Rake::Task["db:schema"].invoke
end