module ScheduleUpdater
  def self.check_and_download
    ManagementResources::Schedule.fetch
  end
end