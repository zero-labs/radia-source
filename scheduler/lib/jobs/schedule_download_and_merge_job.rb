require 'net/http'
require 'uri'

require 'rubygems'
require 'vpim/icalendar'

module Jobs

  class ScheduleDownloadAndMergeJob 

    attr_accessor :structure_templates

    def initialize(structure_templates)
      self.structure_templates = structure_templates
    end

    def load_merged_calendar(filename)
      
    end

    def perform
      merged_calendars = []

      @structure_templates.each do |template|      
        st = YAML::load(template)
        calendar_path = st.calendar_url
        url = URI.parse(calendar_path)
        req = Net::HTTP::Get.new(url.path)
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end
        calendars = Vpim::Icalendar.decode(res.body)
        merged_calendars += calendars
      end

      # Generate a filename with the date of the merge
      prefix = Time.now.strftime("%Y-%m-%d-%H:%M:%S")
      filename = File.join(CALENDAR_MERGE_DIR, "#{prefix}-Merged.ics")
      File.open(filename, 'w') { |f| f.write(merged_calendars) }
      
      # Load the calendar to the system
      load_merged_calendar(filename)
    end
  end

end