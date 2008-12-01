class Settings < ActiveRecord::Base
  include ActiveRecord::Singleton # Forces single record for this model
  
  has_many :asset_services
  has_many :live_sources
end
