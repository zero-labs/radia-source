module EmissionsHelper

  def emissions_calendar(year, month, program = nil)
    d = Date.civil(year, month, 1)
    pe = d.last_month
    ne = d.next_month
    
    prev_url = {:action => 'date_selection', :date => { :year => pe.year, :month => pe.month }, :controller => 'emissions'}
    prev_url.merge!({ :program_id => program.urlname }) if program
    
    next_url = {:action => 'date_selection', :date => { :year => ne.year, :month => ne.month }, :controller => 'emissions'}
    next_url.merge!({ :program_id => program.urlname }) if program
    
    prev_link = link_to_remote("&larr;", :update => "minical", :url => prev_url)
    next_link = link_to_remote("&rarr;", :update => "minical", :url => next_url)
    
    if program.nil?
      emissions = Emission.find_all_by_date(year, month)
      #emissions.collect {}
    else
      emissions = program.find_emissions_by_date(year, month)
    end
    calendar(:year => year, 
             :month => month, 
             :first_day_of_week => 1, 
             :show_today => true, 
             :abbrev => (0..0),
             :previous_month_link => prev_link, 
             :next_month_link => next_link, 
             :program => program) do |date|
      attributes(date, program, emissions)
    end
  end

  def attributes(date, program, emissions)
    if program.nil?
      day_attributes(date, emissions)
    else
      program_day_attributes(date, program, emissions)
    end
  end
  
  def day_attributes(date, emissions)
    if Emission.has_emissions?(date)
      [link_to(date.day, emissions_by_day_path(:year => date.year, :month => date.month, :day => date.day)), { :class => 'emissionDay' }]
    else
      [date.day.to_s, nil]
    end
  end
  
  def program_day_attributes(date, program, emissions)
    if program.has_emissions?(date)
      [link_to(date.day, program_emissions_by_day_path(program, :year => date.year, :month => date.month, :day => date.day)),
        { :class => 'specialDay' }]
    else
      [date.day.to_s, nil]
    end
  end

  def emission_crumbs
    if @program.nil?
      # Global emissions
      @breadcrumbs = [add_crumb("Emissions", emissions_path, true)]
      @breadcrumbs.push add_crumb("#{@date[:year]}", 
                        emissions_by_year_path(:year => @date[:year])) unless @date[:year].blank?			
      @breadcrumbs.push add_crumb("#{Date::MONTHNAMES[@date[:month].to_i]}", 
                        emissions_by_month_path(:year => @date[:year], :month => @date[:month])) unless @date[:month].blank?			
      @breadcrumbs.push add_crumb("#{@date[:day]}", 
                        emissions_by_day_path(:year => @date[:year], :month => @date[:month], :day => @date[:day])) unless @date[:day].blank?
    else
      # Program emissions
      @breadcrumbs = [add_crumb("Programs", programs_path),
                      add_crumb("#{@program.name}", program_path(@program), true),
                      add_crumb("Emissions", program_emissions_path(@program))]
      @breadcrumbs.push add_crumb("#{@date[:year]}", program_emissions_by_year_path(@program)) unless @date[:year].blank?			
      @breadcrumbs.push add_crumb("#{Date::MONTHNAMES[@date[:month].to_i]}", program_emissions_by_month_path(@program)) unless @date[:month].blank?			
      @breadcrumbs.push add_crumb("#{@date[:day]}", program_emissions_by_day_path(@program)) unless @date[:day].blank?			
    end
  end
end
