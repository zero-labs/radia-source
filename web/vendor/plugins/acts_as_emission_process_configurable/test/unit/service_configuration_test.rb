require File.dirname(__FILE__) + '/../test_helper'

class ServiceConfigurationTest < Test::Unit::TestCase
  fixtures :process_configurations
  
  def test_should_have_protocol
    assert_no_difference 'ServiceConfiguration.count' do
      make_service_configuration(:protocol => nil)
    end
  end
  
  def test_should_have_location
    assert_no_difference 'ServiceConfiguration.count' do
      make_service_configuration(:location => nil)
    end
  end
  
  def test_should_have_activity
    assert_no_difference 'ServiceConfiguration.count' do
      make_service_configuration(:activity => nil)
    end
  end
  
  def test_should_have_attrname
    assert_no_difference 'ServiceConfiguration.count' do
      make_service_configuration(:attrname => nil)
    end
  end
  
  def test_should_have_process_configuration
    assert_no_difference 'ServiceConfiguration.count' do
      make_service_configuration(:process_configuration => nil)
    end
  end
  
  def test_should_create_service_configuration
    assert_difference 'ServiceConfiguration.count' do
      make_service_configuration
    end
  end
  
  private 
  
  def make_service_configuration(options = {})
    params = { :protocol => 'ftp', :location => 'www.test.com',
               :activity => 'SomeActivity', :attrname => 'some_name', 
               :process_configuration => process_configurations(:pc) }
    sc = ServiceConfiguration.new(params.merge(options))
    sc.save
    sc
  end
end
