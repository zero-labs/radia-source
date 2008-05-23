require File.dirname(__FILE__) + '/../test_helper'

class SingleAudioAssetTest < ActiveSupport::TestCase
  fixtures :audio_assets

  def test_should_create_single
    assert_difference 'SingleAudioAsset.count' do
      create_single
    end
  end
  
  def test_should_ensure_presence_of_length_unless_unavailable
    assert_difference 'SingleAudioAsset.count' do
      create_single :length => nil, :available => false
    end
    
    assert_no_difference 'SingleAudioAsset.count' do
      create_single :title => 'other title', :length => nil
    end
  end
  
  def test_should_ensure_numericality_of_length
    assert_no_difference 'SingleAudioAsset.count' do
      create_single :title => 'other title', :length => 'a string' # authored and available
    end
  end

  def test_should_be_unavailable
    r = create_single :available => false
    assert_equal true, r.unavailable?
  end
  
  protected
  
  def create_single(options = {})
    defaults = { :length => 320.4, :title => 'Another Brick', :authored => true, :available => true }
    record = SingleAudioAsset.new(defaults.merge(options))
    record.save
    record
  end
end
