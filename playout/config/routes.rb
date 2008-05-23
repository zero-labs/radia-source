ActionController::Routing::Routes.draw do |map|
  map.resources :singles, :collection => { :available => :get, :downloading => :get }
end
