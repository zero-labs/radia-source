module EmissionsHelper

  def emissions_calendar(year, month, program = nil)
    calendar(:year => year, :month => month, :first_day_of_week => 1, :show_today => true, :abbrev => (0..0)) do |date|
      attributes(date, program)
    end
  end

  def attributes(date, program)
    if program.nil?
      day_attributes(date)
    else
      program_day_attributes(date, program)
    end
  end
  
  def day_attributes(date)
    if Emission.has_emissions?(date)
      [link_to(date.day, emissions_by_day_path(:year => date.year, :month => date.month, :day => date.day)), { :class => 'emissionDay' }]
    else
      [date.day.to_s, nil]
    end
  end
  
  def program_day_attributes(date, program)
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
      @breadcrumbs.push add_crumb("#{@date[:month]}", 
                        emissions_by_month_path(:year => @date[:year], :month => @date[:month])) unless @date[:month].blank?			
      @breadcrumbs.push add_crumb("#{@date[:day]}", 
                        emissions_by_day_path(:year => @date[:year], :month => @date[:month], :day => @date[:day])) unless @date[:day].blank?
    else
      # Program emissions
      @breadcrumbs = [add_crumb("Programs", programs_path),
                      add_crumb("#{@program.name}", program_path(@program), true),
                      add_crumb("Emissions", program_emissions_path(@program))]
      @breadcrumbs.push add_crumb("#{@date[:year]}", program_emissions_by_year_path(@program)) unless @date[:year].blank?			
      @breadcrumbs.push add_crumb("#{@date[:month]}", program_emissions_by_month_path(@program)) unless @date[:month].blank?			
      @breadcrumbs.push add_crumb("#{@date[:day]}", program_emissions_by_day_path(@program)) unless @date[:day].blank?			
    end
  end
end
