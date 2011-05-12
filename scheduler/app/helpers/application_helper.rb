# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def arrow
    "<span class=\"arrow\">&rarr;</span>"
  end
  
  def add_crumb(text, link, highlight = false)
    @breadcrumbs = [] if @breadcrumbs.nil?
    @breadcrumbs.push({ :text => text, :link => link, :highlight => highlight })
  end
  
  # The block should be a boolean expression that represents the permissions
  # the user must have for this link to be shown 
  def navigation_item(item, url = {}, separate = false, &block)
    if block_given?
      return unless yield
    end
    path = (url.empty? ? self.send("#{item}_path".to_sym) : url)
    item_class = (separate ? 'separate' : '')
    out = "<li id=\"#{item}_nav\" class=\"#{item_class}\">" 
    out << link_to("#{item.to_s.split('_').collect{|e| e.capitalize}.join(' ')}", 
    path, :class => (@active == "#{item}" ? 'active' : ''))
    out << "</li>"
  end
  
  def alphabetical_list(kollection, member)
    hsh = {}
    letters = ('a'..'z').to_a.insert(0, '#')
    letters.each { |e| hsh[e] = [] }
    
    kollection.each do |el|
      first = el.urlname.split(//)[0]
      if ((el.urlname[0] >= 48) and (el.urlname[0] <= 57))
        hsh['#'] << el
      else
        hsh[first] << el 
      end
    end
    
    render :partial => 'shared/alphabetical', 
           :locals => { :item => member, :items => hsh, :abc => letters }
  end
  
  
  def split_abc_collection(kollection)
    first = {}; second = {};
  	total = kollection.values.flatten.size
  	abc = ('a'..'z').to_a.insert(0, '#')
  	
  	count = 0
  	abc.each do |a| 
  	  if (count + kollection[a].size) < (total / 2)
  	    first[a] = kollection[a]
	    else
	      second[a] = kollection[a]
      end
  	  count += kollection[a].size
	  end
      	
  	[first, second]
  end
  
  
  def broadcasts_calendar(year, month, broadcasts, program = nil)
    d = Date.civil(year, month, 1)
    pe = d.last_month
    ne = d.next_month
    
    prev_url = { :action => 'date_selection', 
                 :date => { :year => pe.year, :month => pe.month }, 
                 :controller => 'broadcasts' }
    prev_url.merge!({ :program_id => program.urlname }) if program
    
    next_url = { :action => 'date_selection', 
                 :date => { :year => ne.year, :month => ne.month }, 
                 :controller => 'broadcasts' }
    next_url.merge!({ :program_id => program.urlname }) if program
    
    prev_link = link_to_remote("&larr;", :update => "minical", :url => prev_url)
    next_link = link_to_remote("&rarr;", :update => "minical", :url => next_url)
    
    sorted = Array.new(d.end_of_month.day) { Array.new }
    broadcasts.each { |e| sorted[e.dtstart.day - 1] << e }
    
    options = { :year => year, :month => month, :first_day_of_week => 1, 
                :show_today => true, :abbrev => (0..0) }
    options.merge!({:previous_month_link => prev_link, :next_month_link => next_link, :program => program })
    
    calendar(options) do |date|
      attributes(date, program, sorted)
    end
  end

  def attributes(date, program, broadcasts)
    if program.nil?
      day_attributes(date, broadcasts)
    else
      program_day_attributes(date, program, broadcasts)
    end
  end
  
  def day_attributes(date, broadcasts)
    if !broadcasts[date.day - 1].empty?
      [link_to(date.day, schedule_broadcasts_by_day_path(:year => date.year, :month => date.month, :day => date.day)), 
        { :class => 'originalDay' }]
    else
      [date.day.to_s, nil]
    end
  end
  
  def program_day_attributes(date, program, broadcasts)
    if !broadcasts[date.day - 1].empty?
      [link_to(date.day, program_broadcasts_by_day_path(program, :year => date.year, :month => date.month, :day => date.day)),
        { :class => 'specialDay' }]
    else
      [date.day.to_s, nil]
    end
  end
  
  def asset_services
    options_from_collection_for_select(AssetService.find(:all), :id, :name)
  end
  
  def mailbox_icon
    icon = if current_user.mailbox[:inbox].unread_mail.empty?
      'email'
    else
      'email_open'
    end
    image_tag "icons/#{icon}.png", :class => 'img_icon'
  end

  def status_icon(broadcast = nil)
    b = broadcast.nil? ? ProgramSchedule.active_instance.now_playing : broadcast
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
    out = "\n<span class=\"as_label\">Status:</span>\n"
    out << image_tag( "icons/#{color}_status.png", :class => 'img_icon', :size => '10x10')
    out << " #{b.pretty_print_status}<br/><br/>"
    
  end
end
