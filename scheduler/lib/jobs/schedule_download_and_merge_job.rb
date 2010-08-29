require 'net/http'
require 'uri'

require 'rubygems'
require 'vpim/icalendar'

module Jobs

  class ScheduleDownloadAndMergeJob 

    attr_accessor :structure_templates, :dtstart, :dtend

    def initialize(args)
      self.structure_templates = args[:structure_templates]
      self.dtstart = Time.now
      self.dtend = args[:dtend]
    end

    def parse_calendars(calendars)
      
    end

    def perform

      # Generate a filename with the date of the merge
      fname_prefix = Time.now.strftime("%Y-%m-%d-%H:%M:%S")
      
      calendars = {}
      @structure_templates.each do |template|      
        calendar_path = template.calendar_url
        url = URI.parse(calendar_path)
        req = Net::HTTP::Get.new(url.path)
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end
        calendar = Vpim::Icalendar.decode(res.body)
        calendars[template.name] = calendar
        filename = File.join(CALENDAR_MERGE_DIR, "#{fname_prefix}_#{template.name}.ics")
        File.open(filename, 'w') { |f| f.write(calendar) }
      end

      #parse_calendars(calendars, dtstart, dtend)
      
    end
  end

end
