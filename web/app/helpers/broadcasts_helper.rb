module BroadcastsHelper

  def broadcast_crumbs
    if @program.nil?
      # Global broadcasts
      add_crumb("Schedule", schedule_path)
      add_crumb("Broadcasts", schedule_broadcasts_path, true)
      add_crumb("#{@date[:year]}", 
                schedule_broadcasts_by_year_path(:year => @date[:year])) unless @date[:year].blank?			
      add_crumb("#{Date::MONTHNAMES[@date[:month].to_i]}", 
                schedule_broadcasts_by_month_path(:year => @date[:year], :month => @date[:month])) unless @date[:month].blank?			
      add_crumb("#{@date[:day]}", 
                schedule_broadcasts_by_day_path(:year => @date[:year], :month => @date[:month], :day => @date[:day])) unless @date[:day].blank?
    else
      # Program broadcasts
      add_crumb("Programs", programs_path)
      add_crumb("#{@program.name}", program_path(@program), true)
      add_crumb("Broadcasts", program_broadcasts_path(@program))
      
      add_crumb("#{@date[:year]}", program_broadcasts_by_year_path(@program)) unless @date[:year].blank?			
      add_crumb("#{Date::MONTHNAMES[@date[:month].to_i]}", program_broadcasts_by_month_path(@program)) unless @date[:month].blank?			
      add_crumb("#{@date[:day]}", program_broadcasts_by_day_path(@program)) unless @date[:day].blank?			
    end
  end
  
  def type_tag(emission)
    type = emission.emission_type
    "<span class=\"#{type.downcase}\">#{type}</span>"
  end
  
  def print_broadcast(broadcast, program = nil)
    render :partial => 'broadcast', :locals => { :broadcast => broadcast, :program => program }
  end 
  
  def program_emission_tag(program, emission)
    
  end
  
  def status_tag(emission)
    emission.status
  end
end
