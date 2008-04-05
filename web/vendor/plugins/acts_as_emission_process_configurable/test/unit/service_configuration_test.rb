require File.dirname(__FILE__) + '/../test_helper'

class ServiceConfigurationTest < Test::Unit::TestCase
  def test_should_have_protocol
    assert_no_difference 'ServiceConfiguration.count' do
      make_service_configuration(:protocol => '')
    end
  end
  
  def test_should_have_location
    assert_no_difference 'ServiceConfiguration.count' do
      make_service_configuration(:location => '')
    end
  end
  
  def test_should_have_activity
    assert_no_difference 'ServiceConfiguration.count' do
      make_service_configuration(:activity => '')
    end
  end
  
  def test_should_create_service_configuration
    assert_difference 'ServiceConfiguration.count' do
      make_service_configuration
    end
  end
  
  private 
  
  def make_service_configuration(options = {})
    params = { :protocol => 'ftp', :location => 'www.test.com', :activity => 'SomeActivity' }
    sc = ServiceConfiguration.new(params.merge(options))
    sc.save
    sc
  end
end
