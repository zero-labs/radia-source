module ProgramScheduleHelper
  def structure_templates
    options_for_select([['Select a structure template...', nil]]) + 
    options_from_collection_for_select( StructureTemplate.find(:all), :id, :name)
  end
  
  def create_original(original, index)
    render(:partial => 'create_broadcast', :locals => { :original => original, :index => index })
  end
  
  def destroy_original(original)
    render(:partial => 'destroy_broadcast', :locals => { :original => original } )
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
