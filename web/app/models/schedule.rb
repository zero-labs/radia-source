require 'singleton'

class Schedule < ActiveRecord::Base
  include Singleton
  
  has_many :schedule_versions
  
  # Attribute for the current schedule version
  def current=(sched_version)
    self.web_active_version = sched_version.id unless sched_version.nil?
  end
  
  def current
    if self.web_active_version.nil?
      return nil
    else
      return schedule_versions.find_by_id(self.web_active_version)
    end
  end
  
  # Creates a new schedule version and switches to it
  def new_version(icalendar)
    return if icalendar.nil?
    # New version & populate with calendar information
    new_version = ScheduleVersion.new(:calendar => icalendar)
    # Add to collection
    self.schedule_versions << new_version
    # Switch to new version
    self.current = new_version
  end
end
