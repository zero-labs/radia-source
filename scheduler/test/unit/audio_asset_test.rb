require File.dirname(__FILE__) + '/../test_helper'

class AudioAssetTest < ActiveSupport::TestCase
  
  def test_should_create_audio_asset
    assert_difference 'AudioAsset.count' do
      create_audio_asset
    end
  end
  
  def test_should_require_title_unless_asset_is_authored
    assert_no_difference 'AudioAsset.count' do
      create_audio_asset :title => nil
    end
    
    assert_no_difference 'AudioAsset.count' do
      create_audio_asset :title => ''
    end
    
    assert_difference 'AudioAsset.count' do
      create_audio_asset :title => nil, :authored => true
    end
  end
  
  def test_should_ensure_title_uniqueness
    create_audio_asset
    
    assert_no_difference 'AudioAsset.count' do
      create_audio_asset :title => 'Hello world'
    end
    
    assert_no_difference 'AudioAsset.count' do
      create_audio_asset :title => 'Hello world', :authored => true
    end
  end
  
  protected 
  
  def create_audio_asset(opts = {})
    defaults = { :title => 'Hello world', :authored => false }
    record = AudioAsset.new(defaults.merge(opts))
    record.save
    record
  end
end
