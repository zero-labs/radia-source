class SchedulesController < ApplicationController
  def index
  end
  
  def new
    @schedule = Schedule.find :first
  end
  
  def create
    @schedule = Schedule.find :first
    if @schedule.new_version(params[:calendar])
      # Success!
    else
      # Problem
    end
  end
  
  private 
  
  def body_id
    @body_id = "schedule"
  end
end
