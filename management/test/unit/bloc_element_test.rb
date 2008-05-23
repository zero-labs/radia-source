require File.dirname(__FILE__) + '/../test_helper'

class BlocElementTest < ActiveSupport::TestCase
  fixtures :blocs, :audio_assets
  
  def test_should_require_audio_asset
    assert_no_difference 'BlocElement.count' do
      create_bloc_element :audio_asset => nil
    end
  end
  
  def test_should_require_bloc
    assert_no_difference 'BlocElement.count' do
      create_bloc_element :bloc => nil
    end
  end
  
  def test_should_create_bloc_element
    assert_difference 'BlocElement.count' do
      create_bloc_element
    end
  end
  
  def test_should
    
  end
  
  protected
  
  def create_bloc_element(options = {})
    defaults = { :bloc => blocs(:author_bloc), :audio_asset => audio_assets(:playlist_1)}
    
    record = BlocElement.new(defaults.merge(options))
    record.save
    record
  end
end
