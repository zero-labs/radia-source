require File.dirname(__FILE__) + '/../test_helper'

class ProgramsControllerTest < ActionController::TestCase
  include AuthenticatedTestHelper
  
  ### Authorization Tests ###
  
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
    
  def test_should_be_editor_for_new_program
    get :new
    assert_redirected_to login_path
    # now log in 
    get_with users(:editor_1), :new
    assert_response :success
  end
  
  def test_should_be_editor_to_create_program
    post :create
    assert_redirected_to login_path
    # now log in 
    post_with users(:editor_1), :create, params_hash
    assert_redirected_to '/programs/hello-world'
  end
  
  def test_should_be_author_to_edit_program
    get :edit, { :id => programs(:program_1).urlname }
    assert_redirected_to login_path
    # now log in 
    get_with users(:quentin), :edit, { :id => programs(:program_1).urlname }
    assert_response :success
    
    get_with users(:quentin), :edit, { :id => programs(:program_2).urlname }
    assert_response :redirect
  end
  
  def test_should_be_editor_to_edit_program
    get_with users(:editor_1), :edit, { :id => programs(:program_2).urlname }
    assert_response :success
  end
  
  def test_should_be_author_to_update_program
    put :update, { :id => programs(:program_2).urlname }
    assert_redirected_to login_path
    # now log in 
    put_with users(:quentin), :update, { :id => programs(:program_1).urlname }.merge(params_hash)
    assert_redirected_to program_path(programs(:program_1))
    
    put_with users(:quentin), :update, { :id => programs(:program_2).urlname }.merge(params_hash)
    assert_redirected_to root_path
  end
  
  def test_should_be_editor_to_update_program
    put_with users(:editor_1), :update, { :id => programs(:program_1).urlname }.merge(params_hash)
    assert_redirected_to program_path(programs(:program_1))
  end
  
  def test_should_be_editor_to_destroy_program
    delete :destroy, { :id => programs(:program_2).urlname }
    assert_redirected_to login_path
    # now log in 
    delete_with users(:editor_1), :destroy, { :id => programs(:program_2).urlname }
    assert_redirected_to programs_path
  end
  
  def test_author_should_not_destroy_program
    delete_with users(:quentin), :destroy, { :id => programs(:program_2).urlname }
    assert_redirected_to root_path
  end
  
  def test_admin_should_be_able_to_manage_program
    get_with users(:admin_1), :new
    assert_response :success
    
    get_with users(:admin_1), :edit, { :id => programs(:program_2).urlname }
    assert_response :success
    
    put_with users(:admin_1), :update, { :id => programs(:program_2).urlname }.merge(params_hash)
    assert_redirected_to program_path(programs(:program_2))
    
    delete_with users(:admin_1), :destroy, { :id => programs(:program_2).urlname }
    assert_redirected_to programs_path
  end
  
  def test_guest_should_only_read_program
    get :show, { :id => programs(:program_1).urlname }
    assert_response :success
    
    get :edit, { :id => programs(:program_2).urlname }
    assert_redirected_to login_path
    
    put :update, { :id => programs(:program_1).urlname }.merge(params_hash)
    assert_redirected_to login_path
    
    delete :destroy, { :id => programs(:program_2).urlname }
    assert_redirected_to login_path
  end
  
  protected 
  
  def params_hash
    { :program => { :name => "Hello World", :active => true, :description => "Yellow!"} }
  end
  
end
