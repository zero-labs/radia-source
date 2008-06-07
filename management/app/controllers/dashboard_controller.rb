class DashboardController < ApplicationController
  before_filter :login_required
  
  helper :broadcasts
  
  # GET /dashboard
  def index
    # index.html.erb
  end
  
  protected
  
  def active_nav
    @active = 'dashboard'
  end
end
