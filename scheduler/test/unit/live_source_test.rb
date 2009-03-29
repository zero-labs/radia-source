require File.dirname(__FILE__) + '/../test_helper'

class LiveSourceTest < ActiveSupport::TestCase
  def test_should_require_url
    assert_no_difference 'LiveSource.count' do
      create_live_source :uri => ''
    end
  end
  
  def test_should_require_name
    assert_no_difference 'LiveSource.count' do
      create_live_source :name => ''
    end
  end
  
  def test_should_create_live_source
    assert_difference 'LiveSource.count' do
      create_live_source
    end
  end
  
  protected
  
  def create_live_source(opts = {})
    defaults = { :uri => 'http://localhost', :name => 'My source' }
    record = LiveSource.new(defaults.merge(opts))
    record.save
    record
  end
end
