module ScheduleUpdater
  def self.check_and_download
    Schedule.fetch
  end
end