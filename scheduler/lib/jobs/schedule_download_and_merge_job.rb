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
    

    def parse_calendars(calendars, dtstop)

      #filter out programs
      programs = []; to_ignore = [];
      calendars.each do |kind, cals|
        RadiaSource::ICal.get_program_names(cals).each do |pname|
          program = Program.find_by_name(pname)
          if program.nil?
            to_ignore << pname
          elsif not programs.include?(program)
            programs << program
          end
        end
      end

      return {:ignored_programs => to_ignore } if not to_ignore.empty?

      broadcasts = []
      now = Time.now
      calendars.each do |kind, cals|
        cals.each do |cal|
          cal.events.each do |ev|
            program = programs.select {|x| x.name.eql? ev.summary }[0]

            ev.occurrences(dtstop) do |dtstart|
              #ignore all dtstarts before dtstart
              next if dtstart < now

              dtend = dtstart + ev.duration

              bc = RadiaSource::LightWeight::Original.new({
                :program => program,
                :structure_template => StructureTemplate.first(:conditions => {:name => kind}),
                :dtstart => dtstart.utc,
                :dtend => dtend.utc })

              broadcasts << bc

            end
          end
        end
      end

      return {:broadcasts => broadcasts}
    end

    def perform
      calendars = load_calendars StructureTemplate.find(:all)

     program_schedule = RadiaSource::LightWeight::ProgramSchedule.instance

     program_schedule.prepare_update
      
      #TODO: break if bc_hashes.has_key? "ignored_programs"
      rt = parse_calendars(calendars, @dtend)

      if rt.has_key?(:broadcasts)
      $dd = rt[:broadcasts]
        rt[:broadcasts].each {|bc| program_schedule.add_broadcast bc }
        program_schedule.save
      end
      
    end
  end

end
