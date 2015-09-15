require 'rake'
require 'rack/test'
require File.expand_path '../../app.rb', __FILE__

ENV['RACK_ENV'] = 'test'

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

  rake = Rake::Application.new
  Rake.application = rake
  rake.init
  rake.load_rakefile

  config.before(:each) do
    rake["db:drop"].invoke
    rake["db:schema"].invoke
  end

  config.after(:each) do
    rake["db:drop"].invoke
    rake["db:schema"].invoke
  end
end


