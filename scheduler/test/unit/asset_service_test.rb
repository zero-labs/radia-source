require File.dirname(__FILE__) + '/../test_helper'

class AssetServiceTest < ActiveSupport::TestCase
  
  def test_should_require_login
    assert_no_difference 'AssetService.count' do
      create_asset_service :login => ''
    end
  end
  
  def test_should_require_protocol
    assert_no_difference 'AssetService.count' do
      create_asset_service :protocol => ''
    end
  end
  
  def test_should_only_accept_recognized_protocols
    assert_no_difference 'AssetService.count' do
      create_asset_service :protocol => 'blabla'
    end
  end
  
  def test_should_create_asset_service
    assert_difference 'AssetService.count' do
      create_asset_service
    end
  end
  
  protected
  
  def create_asset_service(opts = {})
    defaults = { :login => 'test', :uri => 'ftp.example.com', :protocol => 'ftp' }
    record = AssetService.new(defaults.merge(opts))
    record.save
    record
  end
end
