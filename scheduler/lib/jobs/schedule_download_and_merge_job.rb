require 'net/http'
require 'uri'

require 'rubygems'
require 'vpim/icalendar'

module Jobs

  class ScheduleDownloadAndMergeJob 

    attr_accessor :schedule_urls

    def initialize(schedule_urls)
      self.schedule_urls = schedule_urls
    end

    def perform
      merged_calendars = []

      @schedule_urls.each do |calendar_hash|
        calendar_path = calendar_hash[1]
        url = URI.parse(calendar_path)
        req = Net::HTTP::Get.new(url.path)
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end
        calendars = Vpim::Icalendar.decode(res.body)
        merged_calendars += calendars
      end

      # Generate a filename with the date of the merge
      filename = Time.now.strftime("%Y-%m-%d-%H:%M:%S")
      File.open(File.join(CALENDAR_MERGE_DIR, "#{filename}-Merged.ics"), 'w') { |f| f.write(merged_calendars) }
    end
  end

end