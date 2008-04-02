class UsersController < ApplicationController
  layout 'login', :except => :show
  layout 'application', :only => :show
  
  before_filter :check_logged_in, :only => [:new, :create]
  
  # GET /users/new
  def new
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

  # GET /activate/:activation_code
  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end
  
  # GET /users/:id
  # GET /users/:id.:format
  def show
    @user = User.find_by_urlname(params[:id])    
  end
  
  private
  
  def check_logged_in
    redirect_back_or_default(root_path) if logged_in?
  end

end
