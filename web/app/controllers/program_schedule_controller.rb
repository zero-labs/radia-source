class ProgramScheduleController < ApplicationController
  
  # GET /programs/schedule
  # GET /programs/schedule.xml
  def index
    @schedule = ProgramSchedule.instance
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @schedule.to_xml }
    end
  end
  
  # GET /programs/schedule/edit
  def edit
  end
  
  # PUT /programs/schedule
  # TODO PUT xml?
  def update
    respond_to do |format|
      if @schedule.save
        format.html { redirect_to :action => 'index' }
        format.xml { head :ok }
      else
        format.html { render :action => 'new' }
        format.xml { @schedule.errors.to_xml }
    end
  end
end
