class ProcessConfigurationController < ApplicationController
  before_filter :configuration_from_params

  def show

  end
  
  def create
    
  end
  
  def edit
    
  end
  
  def update
    if @process.update_attributes(params[:process])
      flash[:notice] = "Process updated succesfully"
      redirect_to root_path
    else
      flash[:error] = "There were problems updating the process"
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
      @form_path = schedule_process_path
      ProgramSchedule.instance
      
    elsif request.path.include?('programs')
      program = Program.find_by_urlname(params[:program_id])
      @form_path = program_process_path(program)
      program
      
    elsif request.path.include?('emissions')
      #
    end
  end
end
