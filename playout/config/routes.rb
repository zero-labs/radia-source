ActionController::Routing::Routes.draw do |map|
  
  # Audio Assets
  map.resource :audio, :controller => 'audio_assets' do |audio|
    # Logs for all Assets
    audio.datestamped_resources :logs
    
    # Singles
    audio.resources :singles, :collection => { :available => :get, :downloading => :get } do |single|
      # Logs for singles
      single.datestamped_resources :logs
    end
    
    # Spots
    audio.resources :spots, :collection => { :available => :get, :downloading => :get } do |spot|
      # Logs for spots
      spot.datestamped_resources :logs
    end
  end
end
