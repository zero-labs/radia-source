class ScheduleUpdateLogsController < ApplicationController

  # GET /schedule/update_logs
  # GET /schedule/update_logs.:format
  def index
    @update_logs = ScheduleUpdateLog.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @update_logs.to_xml }
    end
  end
end
