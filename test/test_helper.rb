require 'simplecov'
SimpleCov.start
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Test PUT for JSON, from
  # https://gist.github.com/dteoh/2d4c115446e2429824b6945c45c07f3b
  def put_json(path, obj)
    put path, params: obj.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
  end
end
