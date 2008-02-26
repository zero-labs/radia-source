#require 'singleton'

class Schedule < ActiveRecord::Base
  #include Singleton
  
  has_many :schedule_versions
  belongs_to :current, :class_name => 'ScheduleVersion', :foreign_key => 'web_active_version'
  
  # Creates a new schedule version and switches to it
  def new_version!(icalendar)
    # New version & populate with calendar information
    new_version = ScheduleVersion.new(:calendar => icalendar)
    # Add to collection
    self.schedule_versions << new_version
    # Switch to new version
    self.current = new_version
    self.save!
  end
end
