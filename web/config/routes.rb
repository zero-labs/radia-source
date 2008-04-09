ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Site root
  map.root :controller => 'emissions'
  
  # User login
  map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }  
  map.resource :session
  
  # Login route shorthands
  map.login 'login', :controller => 'sessions', :action => 'new', :conditions => { :method => :get }
  map.logout 'logout', :controller => 'sessions', :action => 'destroy', :conditions => { :method => :delete }
  
  # AJAX actions to switch login mode
  map.connect 'sessions/use_open_id', :controller => 'sessions', :action => 'use_open_id', :conditions => { :method => :post }
  map.connect 'sessions/use_normal', :controller => 'sessions', :action => 'use_normal', :conditions => { :method => :post }
  
  # User registration
  map.resources :users
  map.signup 'signup', :controller => 'users', :action => 'new'
  map.activate 'activate/:activation_code', :controller => 'users', :action => 'activate'
  
  # Program schedule
  map.resource :schedule, :controller => 'program_schedule' do |schedule|
    schedule.resource :process, :controller => 'process_configuration', :path_prefix => 'schedule/:process_type'
  end
  
  #map.resources :emissions, :collection => { :recorded => :get, :live => :get, :playlist => :get }
  
  # Emissions (as resources accessible by date)
  map.datestamped_resources :emissions do |emission|
    emission.resource :process, :controller => 'process_configuration', :path_prefix => 'emissions/:year/:month/:day/:id'
  end
  
  
  # AJAX methods for emissions
  map.with_options :controller => 'emissions' do |emission|
    emission.global_date_selection 'emissions/date_selection', :action => 'date_selection'
    emission.program_date_selection 'emissions/:program_id/date_selection', :action => 'date_selection'
  end
  
  # Programs, with nested resources
  map.resources :programs do |program|
    program.datestamped_resources :emissions
    program.resource :process, :controller => 'process_configuration', :path_prefix => 'programs/:program_id/:process_type'
  end
  
  # Radio Editors
  map.resources :editors
  
  # Program Authors
  map.resources :authors
      
  #map.with_options :controller => 'process' do |process|
  #  process.process 'process/:type', :action => 'index', :conditions => {:method => :get}
  #  process.new_process 'process/:type/new', :action => 'new', :conditions => {:method => :get }
  #  process.edit_process 'process/:type/edit', :action => 'edit', :conditions => {:method => :get}
  #  process.update_process 'process/:type/', :action => 'updae', :conditions => {:method => :put }
  #  pr
  #  
  #end
end
