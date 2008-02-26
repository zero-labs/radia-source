class SchedulesController < ApplicationController
  def index
  end
  
  def new
    @schedule = Schedule.find :first
  end
  
  def create
    @schedule = Schedule.find :first
    @schedule.new_version!(params[:calendar])
    
    # html
    redirect_to :action => 'index'
  end
  
  private 
  
  def body_id
    @body_id = "schedule"
  end
end
