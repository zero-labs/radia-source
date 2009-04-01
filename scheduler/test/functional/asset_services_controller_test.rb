require File.dirname(__FILE__) + '/../test_helper'

class AssetServicesControllerTest < ActionController::TestCase
  
  ### Authorization Tests ### 
  
  def test_editor_should_manage_audio_asset_services
    get_with users(:editor_1), :index
    assert_response :success
    assert_not_nil assigns(:asset_services)
    
    get_with users(:editor_1), :show, { :id => asset_services(:asset_service_1) }
    assert_response :success
    assert_not_nil assigns(:asset_service)
    
    # 'browse' AJAX action
    post_with users(:editor_1), :browse, { :id => asset_services(:asset_service_1) }
    assert_response :success
    
    get_with users(:editor_1), :new
    assert_response :success
    
    post_with users(:editor_1), :create, params_hash
    assert_response :redirect
    assert_not_nil assigns(:asset_service)
    
    get_with users(:editor_1), :edit, { :id => asset_services(:asset_service_1) }
    assert_response :success
    
    delete_with users(:editor_1), :destroy, { :id => asset_services(:asset_service_1) }
    assert_redirected_to settings_asset_services_path
  end
  
  def test_admin_should_manage_audio_asset_services
    get_with users(:admin_1), :index
    assert_response :success
    assert_not_nil assigns(:asset_services)
    
    get_with users(:admin_1), :show, { :id => asset_services(:asset_service_1) }
    assert_response :success
    assert_not_nil assigns(:asset_service)
    
    # 'browse' AJAX action
    post_with users(:admin_1), :browse, { :id => asset_services(:asset_service_1) }
    assert_response :success
    
    get_with users(:admin_1), :new
    assert_response :success
    
    post_with users(:admin_1), :create, params_hash
    assert_response :redirect
    assert_not_nil assigns(:asset_service)
    
    get_with users(:admin_1), :edit, { :id => asset_services(:asset_service_1) }
    assert_response :success
    
    delete_with users(:admin_1), :destroy, { :id => asset_services(:asset_service_1) }
    assert_redirected_to settings_asset_services_path
  end
  
  def test_author_should_read_audio_asset_services
    get_with users(:quentin), :index
    assert_response :success
    assert_not_nil assigns(:asset_services)
    
    get_with users(:quentin), :show, { :id => asset_services(:asset_service_1) }
    assert_response :success
    assert_not_nil assigns(:asset_service)
    
    # 'browse' AJAX action
    post_with users(:quentin), :browse, { :id => asset_services(:asset_service_1) }
    assert_response :success
  end
  
  def test_guest_should_not_access_asset_services
    get :index
    assert_redirected_to login_path
    
    get :show, { :id => asset_services(:asset_service_1) }
    assert_redirected_to login_path
    
    get :new
    assert_redirected_to login_path
    
    post :create, params_hash
    assert_redirected_to login_path
    
    get :edit, { :id => asset_services(:asset_service_1) }
    assert_redirected_to login_path
    
    delete :destroy, { :id => asset_services(:asset_service_1) }
    assert_redirected_to login_path
  end
  
  def test_registered_should_not_access_asset_services
    get_with users(:pepe), :index
    assert_redirected_to root_path
    
    get_with users(:pepe), :show, { :id => asset_services(:asset_service_1) }
    assert_redirected_to root_path
    
    get_with users(:pepe), :new
    assert_redirected_to root_path
    
    post_with users(:pepe), :create, params_hash
    assert_redirected_to root_path
    
    get_with users(:pepe), :edit, { :id => asset_services(:asset_service_1) }
    assert_redirected_to root_path
    
    delete_with users(:pepe), :destroy, { :id => asset_services(:asset_service_1) }
    assert_redirected_to root_path
  end
  
  protected
  
  def params_hash
    { :asset_service => { :protocol => 'ftp', :uri => 'localhost', :login => 'anonymous' } }
  end
  
  def created_object
    AssetService.new(params_hash[:asset_service])
  end
end
