# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def arrow
    "<span class=\"arrow\">&rarr;</span>"
  end
  
  def add_crumb(text, link, highlight = false)
    { :text => text, :link => link, :highlight => highlight }
  end
  
  def navigation_item(item, permissions = [], url = {})
    path = (url.empty? ? self.send("#{item}_path".to_sym) : url)
    out = "<li id=\"#{item}_nav\">" 
    out << link_to("#{item.to_s.split('_').collect{|e| e.capitalize}.join(' ')}", 
                    path, :class => (@active == "#{item}" ? 'active' : ''))
    out << "</li>"
  end
  
  def emissions_calendar(year, month, emissions, program = nil)
    d = Date.civil(year, month, 1)
    pe = d.last_month
    ne = d.next_month
    
    prev_url = {:action => 'date_selection', :date => { :year => pe.year, :month => pe.month }, :controller => 'emissions'}
    prev_url.merge!({ :program_id => program.urlname }) if program
    
    next_url = {:action => 'date_selection', :date => { :year => ne.year, :month => ne.month }, :controller => 'emissions'}
    next_url.merge!({ :program_id => program.urlname }) if program
    
    prev_link = link_to_remote("&larr;", :update => "minical", :url => prev_url)
    next_link = link_to_remote("&rarr;", :update => "minical", :url => next_url)
    
    sorted = Array.new(d.end_of_month.day) { Array.new }
    emissions.each { |e| sorted[e.start.day - 1] << e }
    
    options = {:year => year, :month => month, :first_day_of_week => 1, :show_today => true, :abbrev => (0..0)}
    options.merge!({:previous_month_link => prev_link, :next_month_link => next_link, :program => program })
    
    calendar(options) do |date|
      attributes(date, program, sorted)
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
    if !emissions[date.day - 1].empty?
      [link_to(date.day, emissions_by_day_path(:year => date.year, :month => date.month, :day => date.day)), 
        { :class => 'emissionDay' }]
    else
      [date.day.to_s, nil]
    end
  end
  
  def program_day_attributes(date, program, emissions)
    if !emissions[date.day - 1].empty?
      [link_to(date.day, program_emissions_by_day_path(program, :year => date.year, :month => date.month, :day => date.day)),
        { :class => 'specialDay' }]
    else
      [date.day.to_s, nil]
    end
  end
end
