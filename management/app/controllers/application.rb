# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base  
  include AuthenticatedSystem
  
  before_filter :active_nav

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '7ff6ddfc1e3482e81bb3ce53070c5404'
  
  protected 
  
  def schedule
    ProgramSchedule.instance
  end
  
  def active_nav
    @active = 'home'
  end
  
  def broadcast_html_info
    send_date
    broadcasts_for_minical
  end
  
  def send_date
    # Hash for breadcrumbs
    date = [params[:year]  || params[:broadcast_year], 
            params[:month] || params[:broadcast_month], 
            params[:day]   || params[:broadcast_day]]
            
    @date = { :year => date[0], :month => date[1], :day => date[2] }

    # Date object for minicalendar
    if date[2] or date[1]
      @caldate = Date.new(date[0].to_i, date[1].to_i)
    else
      @caldate = Time.now
    end
  end
  
  def broadcasts_for_minical
    year  = params[:year]  || Time.now.year
    month = params[:month] || Time.now.month
    if params[:program_id] 
      @calbroadcasts = @program.find_broadcasts_by_date(year, month) 
    else
      @calbroadcasts = schedule.broadcasts.find_all_by_date(year, month)
    end
  end
end
