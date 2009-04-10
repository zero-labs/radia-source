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
  
  def test_creator_should_exist
    assert_not_nil audio_assets(:created_single).creator
  end
  
  def test_should_only_have_creator_as_author
    assert [audio_assets(:created_single)], audio_assets(:created_single).authors
  end
  
  def test_should_not_have_authors_or_creators
    assert [], audio_assets(:unauthored_single_unavailable).authors
    assert_nil audio_assets(:unauthored_single_unavailable).creator
  end
  
  protected 
  
  def create_audio_asset(opts = {})
    defaults = { :title => 'Hello world', :authored => false }
    record = AudioAsset.new(defaults.merge(opts))
    record.save
    record
  end
end
