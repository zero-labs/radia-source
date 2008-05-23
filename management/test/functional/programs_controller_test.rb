require File.dirname(__FILE__) + '/../test_helper'

class ProgramsControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper
  
  fixtures :programs
  
  def test_should_list_programs
    get :index
    assert_response :success
    assert_not_nil assigns(:programs)
  end
  
  def test_should_show_program
    get :show, { :id => programs(:program_1).urlname }
    assert_response :success
    assert_not_nil assigns(:program)
  end
  
  def test_should_require_login_for_new_program
    get :new
    assert_redirected_to '/login'
    # now log in 
    login_as :quentin
    get :new
    assert_response :success
  end
  
  def test_should_require_login_to_create_program
    post :create
    assert_redirected_to '/login'
    # now log in 
    login_as :quentin
    post :create, params_hash
    assert_redirected_to '/programs/hello-world'
  end
  
  def test_should_require_login_to_edit_program
    get :edit, { :id => programs(:program_2).urlname }
    assert_redirected_to '/login'
    # now log in 
    login_as :quentin
    get :edit, { :id => programs(:program_2).urlname }
    assert_response :success
  end
  
  def test_should_require_login_to_update_program
    put :update, { :id => programs(:program_2).urlname }
    assert_redirected_to '/login'
    # now log in 
    login_as :quentin
    put :update, { :id => programs(:program_2).urlname }.merge(params_hash)
    assert_redirected_to '/programs/hello-world'
  end
  
  def test_should_require_login_to_destroy_program
    delete :destroy, { :id => programs(:program_2).urlname }
    assert_redirected_to '/login'
    # now log in 
    login_as :quentin
    delete :destroy, { :id => programs(:program_2).urlname }
    assert_redirected_to '/programs'
  end
  
  protected 
  
  def params_hash
    { :program => { :name => "Hello World", :active => true, :description => "Yellow!"} }
  end
  
end
