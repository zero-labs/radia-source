class Settings < ActiveRecord::Base
  include ActiveRecord::Singleton # Forces single record for this model
  
  has_many :asset_services
  has_many :live_sources
  
  #def self.current_settings
  #  s = Settings.find(:first)
  #  if s.nil?
  #    s = ProgramSchedule.create(:active => true)
  #  end
  #  return s
  #end
end
