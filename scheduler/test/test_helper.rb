ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.expand_path(File.dirname(__FILE__) + 
        "/../vendor/plugins/declarative_authorization/lib/declarative_authorization/maintenance")
require 'test_help'
#require 'singleton_helper'


class ActiveSupport::TestCase
  
  # Test helpers for Authorization and Authentication plugins
  include Authorization::TestHelper
  include AuthenticatedTestHelper
  
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def reset_singleton(klass)
    klass.reset_instance
    klass.delete_all
  end
  
  def get_calendar_http_response
    require 'yaml'
    return YAML::load_file(File.dirname(__FILE__) + '/util/calendar_http_request.yml')
  end
end
