module EmissionsHelper

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
  
  def type_tag(emission)
    type = emission.emission_type
    "<span class=\"#{type.downcase}\">#{type}</span>"
  end
  
  def status_tag(emission)
    emission.status
  end
end
