require File.dirname(__FILE__) + '/../test_helper'

class ActionConfigurationTest < Test::Unit::TestCase
  fixtures :process_configurations
  
  def test_should_have_some_action
    assert_no_difference 'ActionConfiguration.count' do
      make_action_configuration(:numerical_value => nil)
    end
  end
  
  def test_should_have_perform_flag
    assert_no_difference 'ActionConfiguration.count' do
      make_action_configuration(:perform => nil)
    end
  end
  
  def test_should_have_activity
    assert_no_difference 'ActionConfiguration.count' do
      make_action_configuration(:activity => nil)
    end
  end
  
  def test_should_have_process_configuration
    assert_no_difference 'ActionConfiguration.count' do
      make_action_configuration(:process_configuration => nil)
    end
  end
  
  def test_should_have_attrname
    assert_no_difference 'ActionConfiguration.count' do
      make_action_configuration(:attrname => nil)
    end
  end
  
  def test_should_create_action_configuration
    assert_difference 'ActionConfiguration.count' do
      make_action_configuration
    end
  end
  
  def method_name
    
  end
  
  private
  
  def make_action_configuration(options = {})
    params = { :perform => true, :numerical_value => 1.0, 
               :activity => 'SomeActivity', :attrname => 'some_attr', 
               :process_configuration => process_configurations(:pc)}
    ac = ActionConfiguration.new(params.merge(options))
    ac.save
    ac
  end
end
