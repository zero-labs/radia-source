require File.dirname(__FILE__) + '/../test_helper'

class StructureTest < ActiveSupport::TestCase
  
  def test_should_create_structure
    assert_difference 'Structure.count' do 
      create_structure
    end
  end
  
  def test_should_add_segment
    b = structures(:original_structure)
    p1 = audio_assets(:playlist_1)
    assert_difference 'b.segments.count' do
      b.add_segment(Segment.new(:audio_asset => p1))
      b.save
    end
  end
  
  def test_should_only_allow_one_element_to_have_broadcast_length
    b = structures(:original_structure)
    p1 = audio_assets(:playlist_1)
    s1 = audio_assets(:unauthored_single_unavailable)
    
    assert_difference 'b.segments.count' do
      b.add_segment(Segment.new(:audio_asset => p1, :fill => true))
    end
    
    assert_no_difference 'b.segments.count' do
      b.add_segment(Segment.new(:audio_asset => p1, :fill => true))
    end
    
    assert_difference 'b.segments.count' do
      b.add_segment(Segment.new(:audio_asset => s1, :length => 345, :fill => false))
    end
  end
  
  protected
  
  def create_structure(opts = {})
    defaults = { :playable => structure_templates(:author) }
    record = Structure.new(defaults.merge(opts))
    record.save
    record
  end
 
end
