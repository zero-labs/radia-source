require File.dirname(__FILE__) + '/../test_helper'

class SegmentTest < ActiveSupport::TestCase
  fixtures :blocs, :audio_assets
  
  def test_should_require_audio_asset
    assert_no_difference 'Segment.count' do
      create_segment :audio_asset => nil
    end
  end
  
  def test_should_require_bloc
    assert_no_difference 'Segment.count' do
      create_segment :bloc => nil
    end
  end
  
  def test_should_create_segment
    assert_difference 'Segment.count' do
      create_segment
    end
  end
  
  def test_should
    
  end
  
  protected
  
  def create_segment(options = {})
    defaults = { :bloc => blocs(:author_bloc), :audio_asset => audio_assets(:playlist_1)}
    
    record = Segment.new(defaults.merge(options))
    record.save
    record
  end
end
