
#require File.join(File.dirname(__FILE__), "..", "radia_source", "ical")
require File.join(File.dirname(__FILE__), *%w(.. radia_source ical))

module Jobs

  class ScheduleDownloadAndMergeJob 

    def initialize(args)
      @dtstart = Time.now
      @dtend = args[:dtend]
    end

    def perform
      begin
        log = Kernel::ScheduleUpdateLog.create! :dtstart => Time.now, :status => :initialized
        program_schedule = RadiaSource::LightWeight::ProgramSchedule.instance

        log.status = :downloading
        calendars = RadiaSource::LightWeight::ProgramSchedule.load_calendars Kernel::StructureTemplate.find(:all)

        rt = program_schedule.parse_calendars(calendars, @dtend)

        if not rt[:ignored_repetitions].empty?
          err = { :ignored_programs =>rt[:ignored_programs], :ignored_repetitions=> rt[:ignored_repetitions] }
          log.operation_errors = err.to_yaml
        end


        if not rt.has_key?(:originals) and not rt.has_key?(:repetitions)
          keys = [:originals, :repetitions].select { |x| rt.has_key? x }
          raise RadiaSource::LightWeight::ImportException.new("missing keys (#{__FILE__}:#{__LINE__}): " + keys.to_s )
        end

        log.status = :parsing
        program_schedule.prepare_update
        rt[:originals].each {|bc| program_schedule.add_broadcast! bc }
        rt[:repetitions].each {|bc| program_schedule.add_broadcast! bc }

        log.status = :saving
        if program_schedule.save
          log.status = :completed
        else
          raise RadiaSource::LightWeight::ImportException.new("saving failed (#{__FILE__}:#{__LINE__})")
        end
      rescue RadiaSource::LightWeight::ImportException => e
        log.status = :failed
        log.operation_errors = e.to_operation_log_msg
        puts e
        puts e.backtrace
        return false
      ensure
        log.dtend = Time.now;
        log.save!
      end
    end
  end

end
