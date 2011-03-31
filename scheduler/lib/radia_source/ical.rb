module RadiaSource
  module ICal
    
    # gets all summaries of the given calendars
    def self.get_program_names(calendars)
      names = []

      calendars.each do |cal|
        cal.events do |event|
          names << event.summary
        end
      end
      return names.uniq
    end

    # fetches a calendar from the web.
    # if a name is given, then the calendar is saved
    def self.get_calendar(url_s, name="")
        url = URI.parse(url_s)
        req = Net::HTTP::Get.new(url.path)
        res = Net::HTTP.start(url.host, url.port) do |http|
          http.request(req)
        end
        calendar = self.parse_calendar res.body
        if not name.empty? then
          filename = File.join(CALENDAR_MERGE_DIR, "#{name}.ics")
          File.open(filename, 'w') { |f| f.write(calendar) }
        end
        calendar
    end

    def self.parse_calendar ical_stream
      return Vpim::Icalendar.decode(ical_stream)
    end
  end
end
