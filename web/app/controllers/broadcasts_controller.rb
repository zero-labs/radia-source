class BroadcastsController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :date_selection]
  before_filter :send_date

  # GET /schedule/broadcasts
  # GET /schedule/broadcasts.:format
  # GET /schedule/broadcasts/:year
  # GET /schedule/broadcasts/:year.:format
  # GET /schedule/broadcasts/:year/:month
  # GET /schedule/broadcasts/:year/:month.:format
  # GET /schedule/broadcasts/:year/:month/:day
  # GET /schedule/broadcasts/:year/:month/:day.:format

  # Also, the same requests, scoped by program, like this:
  # GET /programs/:program_id/broadcasts
  def index
    @broadcasts = collection_from_params(params)
    broadcasts_for_minical

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @broadcasts.to_xml(:root => 'broadcasts') }
    end
  end

  # GET /schedule/broadcasts/:year/:month/:day/:id
  # GET /schedule/broadcasts/:year/:month/:day/:id.:format
  # GET /programs/:program_id/broadcasts/:year/:month/:day/:id
  # GET /programs/:program_id/broadcasts/:year/:month/:day/:id.:format
  def show
    program_nav
    @broadcast = schedule.broadcasts.find(params[:id])
    @program = @broadcast.program

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @broadcast.to_xml }
    end
  end

  # AJAX method
  # POST /schedule/broadcasts/date_selection
  def date_selection
    date = Date.new(params[:date][:year].to_i, params[:date][:month].to_i)
    if params[:program_id]
      program = Program.find_by_urlname(params[:program_id])
      broadcasts = program.find_broadcasts_by_date(date.year, date.month)
    else
      broadcasts = schedule.broadcasts.find_all_by_date(date.year, date.month)
    end

    render :partial => 'shared/minical', 
            :locals => { :date => date, :broadcasts => broadcasts, :program => program || nil}
  end

  def new
    
  end

  protected

  def collection_from_params(params)
    send_date
    if params[:program_id]
      program_nav
      @program = Program.find_by_urlname(params[:program_id])
      @program.find_broadcasts_by_date(params[:year], params[:month], params[:day])
    else
      schedule.broadcasts.find_all_by_date(params[:year], params[:month], params[:day])
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

  def send_date
    # Hash for breadcrumbs
    @date = { :year => params[:year], :month => params[:month], :day => params[:day] }
    # Date object for minicalendar
    if params[:day] or params[:month]
      @caldate = Date.new(params[:year].to_i, params[:month].to_i)
    else
      @caldate = Time.now
    end
  end

  def program_nav
    @active = 'programs'
  end

  def active_nav
    @active = 'schedule'
  end
end
