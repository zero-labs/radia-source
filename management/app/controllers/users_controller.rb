class UsersController < ApplicationController
  layout 'login', :only => :new
  layout 'application', :only => [:index, :show, :edit]
  
  before_filter :login_required, :except => [:new, :create, :activate]
  before_filter :check_logged_in, :only => [:new, :create]
  
  # GET /users
  # GET /users.:format
  def index
    @users = User.find(:all, :order => 'name ASC')
    respond_to do |format|
      format.html 
      format.xml { @users.to_xml }
    end
  end
  
  # GET /users/:id
  # GET /users/:id.:format
  def show
    @user = User.find_by_urlname(params[:id])
    @active = 'account' if @user == current_user
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { @user.to_xml }
    end
  end
  
  # GET /users/new
  def new
    @user = User.new
  end

  # POST /users
  # POST /users.:format
  def create
    cookies.delete :auth_token
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      self.current_user = @user
      flash[:notice] = "Thanks for signing up!"
      redirect_back_or_default root_path
    else
      flash[:error] = "There was an error during signup"
      render :action => 'new'
    end
  end
  
  # GET /users/:id/edit
  def edit
    @user = User.find_by_urlname(params[:id])
  end
  
  # POST /users/:id
  # POST /users/:id.:format
  def update
    @user = User.find_by_urlname(params[:id])
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = "Profile updated successfully"
        format.html { redirect_to user_path(@user) }
        format.xml { head :ok }
      else
        flash[:error] = "There were problems updating the profile"
        format.html { render :action => 'edit' }
        format.xml { @user.errors.to_xml }
      end
    end
  end
  
  # DELETE /users/:id
  # DELETE /users/:id.:format
  def destroy
    @user = User.find_by_urlname(params[:id])
    @user.destroy
    
    respond_to do |format|
      flash[:notice] = "User deleted from the system"
      format.html { redirect_to users_path }
      format.xml { head :ok }
    end
  end
  
  # GET /activate/:activation_code
  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end
  
  private
  
  def check_logged_in
    redirect_back_or_default(root_path) if logged_in?
  end
  
  def active_nav
    @active = 'users'
  end

end
