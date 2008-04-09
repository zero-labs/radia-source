class ProgramScheduleController < ApplicationController
  # GET /programs/schedule/edit
  def edit
    @schedule = ProgramSchedule.instance
  end

  # PUT /programs/schedule
  def update
    @schedule = ProgramSchedule.instance
    if @schedule.update_emissions(params[:new_schedule])
      redirect_to :action => 'show'
    else
      redirect_to :action => 'edit'
    end
  end

  protected

  def active_nav
    @active = 'schedule'
  end
end
