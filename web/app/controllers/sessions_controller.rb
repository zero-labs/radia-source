# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'login'
  
  # render new.rhtml
  def new
  end

  def create
    if using_open_id?
      open_id_authentication
    else
      password_authentication(params[:name], params[:password], params[:remember_me] == "1")
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(root_path)
  end
  
  def use_open_id
    render :partial => 'open_id'
  end
  
  def use_normal
    render :partial => 'normal'
  end
  
  protected
  
  # OpenID authentication
  def open_id_authentication
    authenticate_with_open_id(params[:openid_url], :required => [:fullname, :email]) do |result, identity_url, registration|
      if result.successful?
        if @user = User.find_by_identity_url(identity_url)
          {'name=' => 'fullname', 'email=' => 'email'}.each do |attr, reg|
            @user.send(attr, registration[reg]) unless registration[reg].blank?
          end
          unless @user.save
            flash[:error] = "Error saving the fields from your OpenID profile: #{current_user.errors.full_messages.to_sentence}"
          end
          successful_login
        else
          failed_login "Sorry, no user by that identity URL exists (#{identity_url})."
        end
      else
        failed_login result.message
      end
    end
  end
  
  # Method called if using normal authentication
  def password_authentication(login, password, remember_me)
    self.current_user = User.authenticate(login, password)
    if logged_in?
      if remember_me
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      successful_login
    else
      failed_login "Sorry, that username/password doesn't work"
      #render :action => 'new'
    end
  end

  private
  def successful_login
    #self.current_user = @user
    flash[:notice] = "Logged in successfully"
    redirect_back_or_default(root_path)
  end
  
  def failed_login(message)
    flash[:error] = message
    redirect_to(login_path)
  end
end
