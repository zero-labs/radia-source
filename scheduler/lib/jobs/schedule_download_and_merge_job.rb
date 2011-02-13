
#require File.join(File.dirname(__FILE__), "..", "radia_source", "ical")
require File.join(File.dirname(__FILE__), *%w(.. radia_source ical))

module Jobs

  class ScheduleDownloadAndMergeJob 

    def initialize(args)
      @dtstart = Time.now
      @dtend = args[:dtend]
    end

    def perform

      program_schedule = RadiaSource::LightWeight::ProgramSchedule.instance

      

      calendars = RadiaSource::LightWeight::ProgramSchedule.load_calendars StructureTemplate.find(:all)
      #TODO: break if calendars.has_key?(:errors)

      program_schedule.prepare_update

      #TODO: break if bc_hashes.has_key? "ignored_programs"
      rt = program_schedule.parse_calendars(calendars, @dtend)

      if rt.has_key?(:originals)
        #$dd = rt[:originals];
        $drt=rt
          rt[:originals].each {|bc| program_schedule.add_broadcast! bc }
          rt[:repetitions].each {|bc| program_schedule.add_broadcast! bc }
        program_schedule.save
      else
        $drt=rt
        puts "uups", rt.class, rt.keys
      end
    end
  end

end
