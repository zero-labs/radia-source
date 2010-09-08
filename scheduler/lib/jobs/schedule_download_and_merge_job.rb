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
      @program_schedule_id = args[:id]
      @action = args.has_key?("action") ? args["action"] : RadiaSource::ProgramSchedule::Migrate.DefaultAction
      # TODO: if not RadiaSource::ProgramSchedule::Migrate.Actions.include? @action --> ERROR
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
    

    def parse_calendars(calendars, program_schedule, dtstart, dtend, action)
      to_ignore = []; 

      #filter out programs
      #TODO: break if not to_ignore.empty?
      programs = [];
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


      calendars.each do |kind, cals|
        cals.each do |cal|
          cal.events.each do |ev|
            program = programs.select {|x| x.name.eql? ev.summary }[0]

            ev.occurrences(dtend) do |occurrence|
              #ignore all occurrences before dtstart
              next if occurrence < dtstart

              o_dtend = occurrence + ev.duration
              
              bc = { :program_schedule => program_schedule,
                :program => program,
                :structure_template => StructureTemplate.first(:conditions => {:name => kind}),
                :dtstart => occurrence, 
                :dtend => o_dtend }

              conflicts = Conflict.find_in_range(occurrence, o_dtend)
              conflicts.each do |old_conflict|
                if old_conflict.has_dirty_broadcast?
                  old_conflict.action = "manual"
                end

                old_conflict.new_broadcasts << bc
                old_conflict.save
              end

              new_conflict = Conflict.new(:conflicting_old_broadcast => bc, :action => "self")
              new_conflict.save!
              bc.save!

            end
          end
        end
      end
      return to_ignore
    end

    def generate_conflicts(dtstart, dtend, action)

      broadcasts = Broadcast.find_in_range(dtstart, dtend)
      broadcasts.each do |bc|
        conflict = find_or_create_conflict_by_old_broadcast(bc)

        if bc.dirty? or not bc.conflicting_new_broadcasts.empty?
          conflict.update_attributes :action => "manual"
        else
          conflict.update_attributes :action => action
        end

      end
    end

    def delete_void_self_conflicts()
      conflicts = Conflict.find(:all, :conditions => {:action => "self"})

      conflicts.each { |x| x.destroy if x.new_broadcasts.empty? }

    end

    def perform
      calendars = load_calendars StructureTemplate.find(:all)
      
      generate_conflicts(@dtstart, @dtend, @action)
      
      schedule = ProgramSchedule.find(@program_schedule_id)

      ignored_programs = parse_calendars(calendars, schedule, @dtstart, @dtend, @action)
      
      delete_void_self_conflicts()
      
    end
  end

end
