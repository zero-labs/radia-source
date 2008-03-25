ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Site root
  map.root :controller => 'emissions'
  
  # Program schedule
  map.with_options :controller => 'program_schedule' do |schedule|
    #schedule.schedule 'schedule', :action => 'index', :conditions => {:method => :get}
    schedule.edit_schedule 'schedule/edit', :action => 'edit', :conditions => {:method => :get}
    schedule.update_schedule 'schedule', :action => 'update', :conditions => {:method => :put}
  end
  
  # Emissions (as resources accessible by date).
  map.datestamped_resources :emissions
  
  map.with_options :controller => 'emissions' do |emission|
    emission.global_date_selection 'emissions/date_selection', :action => 'date_selection'
    emission.program_date_selection 'emissions/:program_id/date_selection', :action => 'date_selection'
  end
  
  # Programs, with nested resources
  map.resources :programs do |program|
    program.datestamped_resources :emissions
  end
  
  map.with_options :controller => 'programs' do |programs| 
    programs.date_selection 'programs/date_selection/:id', :action => 'date_selection'
  end
end
