class SchedulesController < ApplicationController
  def index
  end
  
  def new
  end
  
  def create
    @schedule = Schedule.new
    @schedule.calendar = params[:calendar]
    if @schedule.save
      render :action => 'index'
    else
      render :action => 'new'
    end
  end
end
