require 'net/http'
require 'uri'

require 'rubygems'
require 'vpim/icalendar'

require File.join(File.dirname(__FILE__), "..", "radia_source", "ical")

module Jobs

  class ScheduleDownloadAndMergeJob 

    def initialize(args)
      @dtstart = Time.now
      @dtend = args[:dtend]
    end


    def load_calendars(templates, filenames = {})
      # Generate a filename with the date of the merge
      fname_prefix = Time.now.strftime("%Y-%m-%d-%H:%M:%S")
      
      calendars = {}
      templates.each do |template|      
        url = filenames.has_key?(template.name) ? filenames[template.name] : template.calendar_url

        calendars[template.name] = RadiaSource::ICal::get_calendar(url, "#{fname_prefix}_#{template.name}")
      end
      
      #calendars["Repetitions"] = RadiaSource::ICal::get_calendar(Settings.instance.repetitions_url, "#{fname_prefix}_repetitions.ics")
      return calendars
    end
    
    def parse_calendars(calendars, dtstart, dtend)
      to_ignore = []; to_create = []; to_destroy = []; conflicting = []

      calendars.each do |kind, cal|
        cal.events.each do |ev|
          to_ignore << ev.summary if not Program.find_by_name ev.summary

          ev.occurrences(dtend) do |occurrence|
            next if occurrences < dtstart

          end
        end
      end
    end

    def perform
      a = StructureTemplate.find(:all)

      templates = StructureTemplate.find(:all)
      calendars = load_calendars(templates)
      return
      parse_calendars(calendars, dtstart, dtend)
      
    end
  end

end
