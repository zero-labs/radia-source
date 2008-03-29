# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base  
  include AuthenticatedSystem
  
  helper :all # include all helpers, all the time
  before_filter :active_nav

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '7ff6ddfc1e3482e81bb3ce53070c5404'
  
  protected 
  
  def active_nav
    @active = 'home'
  end
end
