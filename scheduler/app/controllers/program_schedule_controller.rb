class ProgramScheduleController < ApplicationController
  before_filter :login_required, :except => :show
  before_filter :setup_minical
  
  helper :broadcasts  
  
  # GET /schedule
  # GET /schedule.:format
  def show
    @schedule = schedule
    respond_to do |format|
      format.html do
        @broadcasts = schedule.broadcasts_and_gaps(Time.now.utc, 1.day.from_now.utc) 
        # renders show.html.erb
      end
      format.xml do 
        except = [:id, :created_at, :updated_at]
        render :xml => @schedule.to_xml(:except => except)
      end
    end
  end
  
  # GET /schedule/edit
  def edit
    @schedule = schedule
  end

  # PUT /schedule
  def update
    
    @schedule = schedule
    
    # dtstart = (params[:start] ? ProgramSchedule.get_datetime(params[:start]) : Time.now)
    dtend = ProgramSchedule.get_datetime(params["new_schedule"]["end"])

    j = Jobs::ScheduleDownloadAndMergeJob.new(:dtend => dtend)
    j.perform #sync
    #Delayed::Job.enqueue(j) # TODO change to async

    flash[:notice] = "The schedule is being updated"
    redirect_to :action => 'show'
  end

  protected
  
  def setup_minical
    @caldate = Time.now
    @calbroadcasts = schedule.broadcasts.find_all_by_date(Time.now.year, Time.now.month)
  end

  def active_nav
    @active = 'schedule'
  end
end
