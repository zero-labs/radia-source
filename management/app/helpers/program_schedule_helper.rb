module ProgramScheduleHelper
  def emission_types
    options_for_select([['Select a structure template...', nil]]) + 
    options_from_collection_for_select( EmissionType.find(:all), :id, :name)
  end
  
  def create_emission(emission, index)
    render(:partial => 'create_emission', :locals => { :emission => emission, :index => index })
  end
  
  def destroy_emission(emission)
    render(:partial => 'destroy_emission', :locals => { :emission => emission } )
  end
  
  def ignored_programs(result_array)
    result_array[1].each do |p|
      render :partial => 'ignored_program', :object => p
    end
  end
  
  def print_broadcast(broadcast, program = nil)
    render :partial => 'broadcasts/broadcast', :locals => { :broadcast => broadcast, :program => program }
  end
end
