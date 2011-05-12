ENV["RAILS_ENV"] = "test"
RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + "/../../../") unless defined?(RAILS_ROOT)

require "#{RAILS_ROOT}/config/environment"
require 'test_help'

CAL1_TOTAL_ORIGINALS = 4
CAL1_TOTAL_REPETITIONS = 4
CAL3_TOTAL_ORIGINALS = 21
CAL3_TOTAL_REPETITIONS = 4
NS=RadiaSource::LightWeight

#class NS::TestCase<ActiveSupport::TestCase
 class NS::TestCase 
  #self.fixture_path = File.expand_path(RAILS_ROOT + "/test/fixtures/lightweight")

  def self.fixtures(*dummy)
  end
    def self.fixture_path
      File.expand_path(RAILS_ROOT + "/test/fixtures/lightweight")
    end

  # self.use_transactional_fixtures = true
  # self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...
  def reset_singleton(klass)
    klass.reset_instance
    klass.delete_all
  end
  
end
