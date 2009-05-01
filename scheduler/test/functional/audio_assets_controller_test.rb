require File.dirname(__FILE__) + '/../test_helper'

class AudioAssetsControllerTest < ActionController::TestCase
  
  ### Authorization Tests ###
  
  def test_guest_should_read_audio_assets
    get :show
    assert_response :success
  end
  
  def test_registered_should_read_audio_assets
    get :show
    assert_response :success
  end
  
  def test_authors_should_read_and_update_audio_assets
    get :show
    assert_response :success
  end
end
