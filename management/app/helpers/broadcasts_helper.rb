module BroadcastsHelper

  def broadcast_crumbs
    if @program.nil?
      # Global broadcasts
      add_crumb("Schedule", schedule_path)
      add_crumb("Broadcasts", schedule_broadcasts_path, true)
      if @date
        add_crumb("#{@date[:year]}", 
                  schedule_broadcasts_by_year_path(:year => @date[:year])) unless @date[:year].blank?			
        add_crumb("#{Date::MONTHNAMES[@date[:month].to_i]}", 
                  schedule_broadcasts_by_month_path(:year => @date[:year], :month => @date[:month])) unless @date[:month].blank?			
        add_crumb("#{@date[:day]}", 
                  schedule_broadcasts_by_day_path(:year => @date[:year], :month => @date[:month], :day => @date[:day])) unless @date[:day].blank?
      end
    else
      # Program broadcasts
      add_crumb("Programs", programs_path)
      add_crumb("#{@program.name}", program_path(@program), true)
      add_crumb("Broadcasts", program_broadcasts_path(@program))
      
      add_crumb("#{@date[:year]}", 
        program_broadcasts_by_year_path(@program, :year => @date[:year])) unless @date[:year].blank?
    
      add_crumb("#{Date::MONTHNAMES[@date[:month].to_i]}", 
        program_broadcasts_by_month_path(@program, :year => @date[:year], 
                                                   :month => @date[:month])) unless @date[:month].blank?			
        
      add_crumb("#{@date[:day]}", 
        program_broadcasts_by_day_path(@program, :year => @date[:year], 
                                                 :month => @date[:month], 
                                                 :day => @date[:day])) unless @date[:day].blank?			
    end
  end
  
  def type_tag(broadcast)
    if broadcast.kind_of?(Repetition)
      color = '#ccc'
      type = 'Repetition'
    elsif broadcast.kind_of?(Gap)
      color = '#FA8072'
      type = 'Gap'
    else
      type = broadcast.emission_type.name
      color = broadcast.emission_type.color
    end
    "<span class=\"type_tag\" style=\"background:#{color}\">#{type}</span>"
  end
  
  def print_broadcast(broadcast, program = nil)
    render :partial => 'broadcasts/broadcast', :locals => { :broadcast => broadcast, :program => program }
  end 
  
  def small_print_broadcast(broadcast, program = nil)
    render :partial => 'broadcasts/small_broadcast', :locals => { :broadcast => broadcast }
  end
  
  def status_icon(broadcast = nil)
    b = broadcast.nil? ? ProgramSchedule.instance.now_playing : broadcast
    color = case b.status
    when :pending
      'red'
    when :delivered
      'yellow'
    when :available
      'green'
    when :partial
      'yellow'
    end
    out = image_tag "icons/#{color}_status.png", :class => 'img_icon', :size => '10x10'
    out << "\n<span class=\"as_label\"> #{b.pretty_print_status} </span>"
  end
end
