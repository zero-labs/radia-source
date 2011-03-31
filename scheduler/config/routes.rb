ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Site root
  map.root :controller => 'dashboard', :action => 'index'
  
  # User login
  map.open_id_complete 'session', :controller => 'sessions', :action => 'create', :requirements => { :method => :get }  
  map.resource :session
  
  # Login route shorthands
  map.login 'login', :controller => 'sessions', :action => 'new', :conditions => { :method => :get }
  map.logout 'logout', :controller => 'sessions', :action => 'destroy', :conditions => { :method => :delete }
  
  # Users
  map.resources :users do |user|
    user.resources :mailboxes, :member => { :empty => :post } do |box|
      box.resources :messages
    end
  end
  # Registration
  map.signup 'signup', :controller => 'users', :action => 'new'
  map.activate 'activate/:activation_code', :controller => 'users', :action => 'activate'
  
  # Program schedule
  map.resource :schedule, :controller => 'program_schedule' do |schedule|
    
    # Broadcasts (as resources accessible by date)
    schedule.datestamped_resources :broadcasts do |broadcast|
      broadcast.resources :templates, :controller => 'structure_templates', 
                        :path_prefix => 'schedule/broadcasts', :name_prefix => 'schedule_structure_'                
    end
    
    schedule.resources :editors
    schedule.gaps 'gaps', :controller => 'gaps'
    schedule.resources :update_logs, :controller => 'schedule_update_logs'
    schedule.resources :conflicts, :controller => 'schedule_conflicts'
  end
    
  # Programs, with nested resources
  map.resources :programs do |program|
    program.datestamped_resources :broadcasts do |broadcast|
      broadcast.resource :delivery
    end
    program.resources :authors, :controller => 'program_authors'
  end  
  
  # Program Authors
  map.resources :authors
  
  # Audio Assets
  map.resource :audio, :controller => 'audio_assets' do |asset|
    asset.resources :playlists
    asset.resources :singles, :collection => { :unavailable => :get }
    asset.resources :spots, :collection => { :unavailable => :get }
  end
  
  # System settings
  map.resource :settings do |settings|
    settings.resources :asset_services
    settings.resources :live_sources
  end
  
  map.dashboard 'dashboard', :controller => 'dashboard'
  
  ### Routes for AJAX methods
  
  # Switch login mode
  map.connect 'sessions/use_open_id', :controller => 'sessions', :action => 'use_open_id', :conditions => { :method => :post }
  map.connect 'sessions/use_normal', :controller => 'sessions', :action => 'use_normal', :conditions => { :method => :post }
  
  # Date selection for minicalendar
  map.with_options :controller => 'broadcasts' do |original|
    original.global_date_selection 'schedule/broadcasts/date_selection', 
                                    :action => 'date_selection', :conditions => { :method => :post }
    original.program_date_selection 'schedule/broadcasts/:program_id/date_selection', 
                                    :action => 'date_selection', :conditions => { :method => :post }
  end
  
  # Structure elements
  map.with_options :controller => 'structure_templates' do |structure_template|
    structure_template.show_segment 'schedule/broadcasts/types/:id/show_segment', 
                                    :action => 'show_segment', :conditions => { :method => :post }
    structure_template.create_segment 'schedule/broadcasts/types/:id/create_segment', 
                                    :action => 'create_segment', :conditions => { :method => :put }
    
  end
  
  # Asset services
  map.asset_service_browser 'settings/asset_services/browse',:controller => 'asset_services', 
                            :action => 'browse', :conditions => { :method => :post }
                        
  # Message recipients
  map.with_options :controller => 'messages' do |message|
    message.add_recipient '/users/:user_id/mailboxes/sentbox/messages',
                          :action => 'add_recipient', :conditions => { :method => :post }
    message.remove_recipient '/users/:user_id/mailboxes/sentbox/messages',
                              :action => 'remove_recipient', :conditions => { :method => :post }
  end
end
