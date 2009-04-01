class DashboardController < ApplicationController
  before_filter :login_required
  
  helper :broadcasts
  
  # GET /dashboard
  def index
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  protected
  
  def active_nav
    @active = 'dashboard'
  end
end
