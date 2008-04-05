require File.dirname(__FILE__) + '/../test_helper'

class ActionConfigurationTest < Test::Unit::TestCase
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
  
  def test_should_create_action_configuration
    assert_difference 'ActionConfiguration.count' do
      make_action_configuration
    end
  end
  
  private
  
  def make_action_configuration(options = {})
    params = { :perform => true, :numerical_value => 0.0, :activity => 'SomeActivity' }
    ac = ActionConfiguration.new(params.merge(options))
    ac.save
    ac
  end
end
