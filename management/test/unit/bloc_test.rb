require File.dirname(__FILE__) + '/../test_helper'

class BlocTest < ActiveSupport::TestCase
  fixtures :blocs, :emission_types, :audio_assets
  
  def test_should_create_bloc
    assert_difference 'Bloc.count' do 
      create_bloc
    end
  end
  
  def test_should_add_segment
    b = blocs(:emission_bloc)
    p1 = audio_assets(:playlist_1)
    assert_difference 'b.segments.count' do
      b.add_segment(Segment.new(:audio_asset => p1))
      b.save
    end
  end
  
  def test_should_only_allow_one_element_to_have_broadcast_length
    b = blocs(:emission_bloc)
    p1 = audio_assets(:playlist_1)
    s1 = audio_assets(:unauthored_single_not_present)
    
    assert_difference 'b.segments.count' do
      b.add_segment(Segment.new(:audio_asset => p1, :fill => true))
    end
    
    assert_no_difference 'b.segments.count' do
      b.add_segment(Segment.new(:audio_asset => p1, :length => true))
    end
    
    assert_difference 'b.segments.count' do
      b.add_segment(Segment.new(:audio_asset => s1, :length => 345, :fill => false))
    end
  end
  
  protected
  
  def create_bloc(opts = {})
    defaults = { :playable => emission_types(:author) }
    record = Bloc.new(defaults.merge(opts))
    record.save
    record
  end
 
end
