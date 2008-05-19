require File.dirname(__FILE__) + '/../test_helper'

class BlocTest < ActiveSupport::TestCase
  fixtures :blocs, :emission_types, :audio_assets
  
  def test_should_create_bloc
    assert_difference 'Bloc.count' do 
      create_bloc
    end
  end
  
  def test_should_add_element
    b = blocs(:emission_bloc)
    p1 = audio_assets(:playlist_1)
    assert_difference 'b.elements.count' do
      b.add_element(BlocElement.new(:audio_asset => p1))
      b.save
    end
  end
  
  def test_should_only_allow_one_element_to_have_broadcast_length
    b = blocs(:emission_bloc)
    p1 = audio_assets(:playlist_1)
    s1 = audio_assets(:unauthored_single_not_present)
    
    assert_difference 'b.elements.count' do
      b.add_element(BlocElement.new(:audio_asset => p1, :length => nil))
    end
    
    assert_no_difference 'b.elements.count' do
      b.add_element(BlocElement.new(:audio_asset => p1, :length => nil))
    end
    
    assert_difference 'b.elements.count' do
      b.add_element(BlocElement.new(:audio_asset => s1, :length => 345))
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
