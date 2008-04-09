class ProcessConfigurationController < ApplicationController
  before_filter :configuration_from_params

  def show
  end
  
  def new
  end
  
  def create
  end
  
  def edit
  end
  
  def update
    if @process.update_attributes(params[:process])
      flash[:notice] = "Process configuration updated succesfully"
      redirect_to root_path
    else
      flash[:error] = "There were problems updating the process configuration."
      redirect_to :action => 'edit'
    end
  end

  def destroy
    
  end
  
  protected
  
  def configuration_from_params
    @type = params[:process_type]
    @processable = processable_from_path
    if @processable.has_process? @type
      @process = @processable.send(@type.to_sym)
    else
      flash[:error] = "That type of process does not exist for the selected element."
      redirect_back_or_default root_path
    end
  end
  
  def processable_from_path
    if request.path.include?('schedule')
      schedule_active
      @form_path = schedule_process_path
      ProgramSchedule.instance
      
    elsif request.path.include?('programs')
      programs_active
      program = Program.find_by_urlname(params[:program_id])
      @form_path = program_process_path(program)
      program
      
    elsif request.path.include?('emissions')
      emissions_active
      #
    end
  end
  
  def schedule_active
    @active = 'schedule'
  end
  
  def programs_active
    @active = 'programs'
  end
  
  def emissions_active
    @active = 'emissions'
  end
end
