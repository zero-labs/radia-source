class BroadcastsController < ApplicationController
  before_filter :login_required, :except => [:index, :show, :date_selection]

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
    collection_from_params

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @broadcasts.to_xml(:root => 'broadcasts') }
    end
  end

  # GET /schedule/broadcasts/:year/:month/:day/:id
  # GET /schedule/broadcasts/:year/:month/:day/:id.:format
  # GET /programs/:program_id/broadcasts/:year/:month/:day/:id
  # GET /programs/:program_id/broadcasts/:year/:month/:day/:id.:format
  def show
    element_from_params

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @broadcast.to_xml }
    end
  end
  
  
  def new
  end

  # AJAX methods
  
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
            :locals => { :date => date, :broadcasts => broadcasts, :program => program || nil }
  end

  protected
  
  def element_from_params
    @broadcast = schedule.broadcasts.find(params[:id])
    @program = @broadcast.program
    broadcast_html_info
  end

  def collection_from_params    
    @broadcasts = if params[:program_id]
      @program = Program.find_by_urlname(params[:program_id])
      @program.find_broadcasts_by_date(params[:year], params[:month], params[:day])
    else
      schedule.broadcasts.find_all_by_date(params[:year], params[:month], params[:day])
    end
    broadcast_html_info
  end

  def active_nav
    @active = params[:program_id] ? 'programs' : 'schedule'
  end
end
