module RadiaSource
  module LightWeight


    class ProgramSchedule
      require 'singleton'
      include Singleton

      attr_accessor :broadcasts, :conflicts, :to_destroy

      ### Instance methods
      #

      def initialize(t1=Time.now,persist=true)
        @last_update = t1

        if persist
          self.load_persistent_objects(@last_update) 
        else
          @broadcasts= []
          @to_destroy= []
          @conflicts = []
        end
      end


      def find_in_range(dtstart, dtend)
        @broadcasts.select do |x|
          (x.dtstart < dtstart and x.dtend > dtstart) or
          (x.dtstart >=dtstart and x.dtstart < dtend)
        end
      end



      #  older broadcasts are marked to be destroyed
      #  conflicts are created

      def prepare_update
        # All elder broadcasts are trash...
        tmp = @broadcasts; 
        @broadcasts = []
        @to_destroy = tmp.reject {|bc| bc.dirty?}
        # TODO: this puts returns 0,0 at 2 time it runs
        puts tmp.count, @to_destroy.count

        # Get rid of unsolved, conflicts with unactivated broadcasts
        @conflicts = @conflicts.reject{|c| c.active_broadcast.nil?}

        # Clean all unactivated broadcasts from remaining conflicts
        @conflicts.each {|c| c.new_broadcasts = [] }

        # unless somebody used them
        tmp.select { |bc| bc.dirty? }.each do |bc|
          self.add_conflict( :conflict => find_or_create_conflict_by_active_broadcast(bc) )
        end
      end

      def add_broadcast bc

        # Find intersection with a known conflict
        tmp = @conflicts.select { |c| c.intersects?(bc) }
        
        if tmp.empty?
          self.add_conflict(:new_broadcasts => [bc])
        else
          tmp.each { |c| c.add_new_broadcast bc }
        end

        # if possible, avoid destroying and re-creating
        # similar broadcasts. Let's see if we cand find 
        # something similar that we can reuse

        #tmp = @to_destroy.find {|broadcast| bc.similar? broadcast}
        #unless tmp.nil?
        #  # POTENTIAL BUG! Should test kind_of? ActiveRecord::Base
        #  # before assigment. Yet to_destroy list is constructed from
        #  # dirty broadcasts that should allways be AR )

        #  bc.persistent_object = tmp.persistent_object
        #  @to_destroy.delete(tmp)
        #end

        @broadcasts << bc
        bc
      end


      def self.load_calendars(templates, filenames = {})
        # Generate a filename with the date of the merge
        fname_prefix = Time.now.strftime("%Y-%m-%d-%H:%M:%S")

        calendars = {}
        templates.each do |template|      
          url = filenames.has_key?(template.name) ? filenames[template.name] : template.calendar_url

          begin
            calendars[template.name] = RadiaSource::ICal::get_calendar(url, "#{fname_prefix}_#{template.name}")
          rescue
            return { :__error => "calendar for #{template.name} not available" }
          end
        end

        begin
          calendars["Repetitions"] = RadiaSource::ICal::get_calendar(Settings.instance.repetitions_url, "#{fname_prefix}_repetitions.ics")
        rescue
          return { :__error => "calendar for repetitions not available" }
        end
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

        broadcasts = []; repetitions = []
        now = Time.now

        original_show_calendars = calendars.reject {|k,v| k == "Repetitions"} 
        original_show_calendars.each do |kind, cals|
          cals.each do |cal|
            cal.events.each do |ev|
              program = programs.select {|x| x.name.eql? ev.summary }[0]

              ev.occurrences(dtstop) do |dtstart|
                #ignore all ocurrences before now
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


        ignored_repetitions = []
        if calendars.has_key?("Repetitions") then
          calendars["Repetitions"].each do |cal|
            cal.events.each do |ev|
              program = programs.find {|x| x.name.eql? ev.summary }

              original_broadcasts = broadcasts.select { |bc| bc.program.eql?(program) and bc.kind_of?(RadiaSource::LightWeight::Original) }
              ev.occurrences(dtstop) do |dtstart|
                #ignore all ocurrences before now
                next if dtstart < now

                # Ensure the UTC time ref
                dt = dtstart.utc
                dtend = dt + ev.duration

                # repetition is nonsense if there is no original which
                # ends before the repetition starts
                #TODO: What to do with ignored repetitions?
                bcs = original_broadcasts.select { |bc| bc.dtend < dt }
                if bcs.empty?
                  # Find if any of the older (unaffected by the import)
                  # matches to use it as the original
                  original = Kernel::Broadcast.find_first_sooner_than(dt, program, "Original")
                  if original.nil?
                    ignored_repetitions << { :program => program.name, :dtstart => dt, :dtend => dtend}
                    next
                  else
                    original = RadiaSource::LightWeight::Original.from_ar(original)
                  end
                else
                  original = bcs.max {|a,b| a.dtend <=> b.dtend } 
                end

                #puts "#{original.object_id.to_s(16)}, " +original.to_s + "."
                bc = RadiaSource::LightWeight::Repetition.new({
                  :original => original,
                  :dtstart => dt,
                  :dtend => dtend.utc })
                  repetitions << bc
              end
            end
          end
        end

        return {:originals => broadcasts, :repetitions => repetitions, :ignored_repetitions => ignored_repetitions}

      end

      def save
        #Lets solve as much conflicts as possible
        tmp = @conflicts.select {|c| c.solvable? }
        tmp.each do |c| 
          c.solved_to_destroy.each do |bc| 
            @broadcasts.delete(bc)
            bc.destroy
          end
          @conflicts.delete(c)
        end

        # Lets save
        @to_destroy.each { |bc| bc.destroy }
        $destroy = @to_destroy
        @broadcasts.each { |bc| bc.save }
        @conflicts.each { |c| c.save }
        
        @broadcasts.each { |bc| bc.activate }
      end


      def find_or_create_conflict_by_active_broadcast(bc)
        tmp = @conflicts.find { |c| c.active_broadcast.eql?(bc) }
        if tmp.nil?
          return Conflict.new(:active_broadcast => bc)
        end
        return tmp
      end

      #protected

      def load_persistent_objects(t1=Time.now)
        @broadcasts = Kernel::Broadcast.find_greater_than(t1, false).map do |bc|
          case bc.attributes["type"]
          when "Original" then RadiaSource::LightWeight::Original.from_ar(bc)
          when "Repetition" then RadiaSource::LightWeight::Repetition.from_ar(bc)
          else RadiaSource::LightWeight::Broadcast.from_ar(bc)
          end
        end
        @conflicts = Kernel::Conflict.all.map {|c| Conflict.from_ar(c) }
        #@conflicts = []
      end

      def add_conflict(params)
        if params.has_key? :conflict
          if @conflicts.find {|c| c.active_broadcast == params[:conflict].active_broadcast}.nil?
            @conflicts << params[:conflict]
          end
        else
          @conflicts << Conflict.new(params)
        end
      end

    end


  
  end
end
