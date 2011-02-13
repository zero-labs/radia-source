module RadiaSource
  module LightWeight


    class ProgramSchedule
      require 'singleton'
      include Singleton

      attr_accessor :broadcasts, :to_move, :to_destroy

      def self.move_to_limbo(proxy_bc)
        bc = proxy_bc.po
        if bc.kind_of? ActiveRecord::Base
          bc.update_attribute :program_schedule, Kernel::ProgramSchedule.limbo_instance
          true
        else
          false
        end
      end


      ### Instance methods

      def initialize(t1=Time.now,persist=true)
        @last_update = t1

        if persist
          self.load_persistent_objects(@last_update) 
        else
          @active_broadcasts = []
          @broadcasts= []
          @to_destroy= []
          @timeframes= []
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
        # All elder broadcasts and conflicts are trash...
        tmp = @broadcasts
        @to_destroy = tmp.reject {|bc| bc.dirty?}
        @broadcasts = []

        # unless somebody used them
        @to_move = tmp.select { |bc| bc.dirty? }
      end

      def add_broadcast! bc

        # If any of the old broadcasts is similar, than it is 
        # re-used. This is done here automatically since the
        # user will probably do it manually

        tmp = @to_move.find {|broadcast| bc.similar? broadcast}
        unless tmp.nil? or tmp.po.nil?
          bc.persistent_object = tmp.persistent_object
          @to_move.delete(tmp)
        end

        #
        #tmp = @to_destroy.find {|broadcast| bc.similar? broadcast}
        #unless tmp.nil?
        #  # POTENTIAL BUG! Should test kind_of? ActiveRecord::Base
        #  # before assigment. Yet to_destroy list is constructed from
        #  # dirty broadcasts that should allways be AR )

        #  bc.persistent_object = tmp.persistent_object
        #  @to_destroy.delete(tmp)
        #end

        self.add_timeframe_from_broadcast bc

        @broadcasts << bc
        bc
      end

      def add_timeframe_from_broadcast bc
        new_frame = TimeFrame.new :broadcast => bc
        
        # Find intersection with  known timeframes
        tframes = @timeframes.select { |tf| tf.intersects?(new_frame) }
         
        if tframes.empty?
          @timeframes << new_frame
        else
          tmp = TimeFrame.merge new_frame, tframes
          @timeframes.reject! {|tf| tframes.include?(tf) } 
          @timeframes << tmp
        end
      end

      def self.load_calendars(templates, filenames = {})
        # Generate a filename with the date of the merge
        fname_prefix = Time.now.strftime("%Y-%m-%d-%H:%M:%S")

        originals = {}; errors = []
        templates.each do |template|      
          url = filenames.has_key?(template.name) ? filenames[template.name] : template.calendar_url

          begin
            originals[template.name] = RadiaSource::ICal::get_calendar(url, "#{fname_prefix}_#{template.name}")
          rescue
            errors <<  "calendar for #{template.name} not available"
          end
        end

        begin
          repetitions = RadiaSource::ICal::get_calendar(Settings.instance.repetitions_url, "#{fname_prefix}_repetitions.ics")
        rescue
           errors << "calendar for repetitions not available"
        end
        unless errors.empty?
          return {:errors => errors}
        end
        return { :originals => originals,  :repetitions => repetitions }
      end

      def parse_calendars(calendars, dtstop, now=Time.now.utc)

        #filter out programs
        programs = []; to_ignore = [];

        (calendars[:originals].merge({:repetitions => calendars[:repetitions]})).each do |kind, cals|
          RadiaSource::ICal.get_program_names(cals).each do |pname|
            program = Program.find_by_name(pname)
            if program.nil?
              to_ignore << pname
            elsif not programs.include?(program)
              programs << program
            end
          end
        end


        broadcasts = []; repetitions = []
        

        calendars[:originals].each do |kind, cals|
          cals.each do |cal|
            cal.events.each do |ev|
              program = programs.find {|x| x.name == ev.summary }
              next if program.nil?

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
        calendars[:repetitions].each do |cal|
          cal.events.each do |ev|
            program = programs.find {|x| x.name == ev.summary }
            next if program.nil?

            original_broadcasts = broadcasts.select { |bc| bc.program.eql?(program) }
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
                original = Kernel::Original.find_first_sooner_than(dt, program, :type => 'Original')
                if original.nil?
                  ignored_repetitions << { :program => program.name, :dtstart => dt, :dtend => dtend}
                  next
                else
                  original = RadiaSource::LightWeight::Original.new_from_persistent_object(original)
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

        return {:originals => broadcasts, :repetitions => repetitions, :ignored_repetitions => ignored_repetitions, :ignored_programs => to_ignore}

      end

      def save
        # kill all inactive broadcasts
        #@conflicts.each {|c| c.destroy} #do we need this ? Some callback of broadcast should do it
        Kernel::Conflict.delete_all
        @inactive_broadcasts.each {|x| x.destroy }

        # fails if any timeframe with more than one broadcast
        tmp = @timeframes.select {|tf| tf.broadcasts.length > 1}
        if tmp.empty? # All right!
          @broadcasts.each {|bc| bc.save }
          @to_move.each { |x| self.class.move_to_limbo(x) }

          Kernel::Broadcast.delete @to_destroy.map{|x| x.po.id }
          @broadcasts.each {|bc| bc.activate }
          return true
        else
          tmp.each do |tf|
            tf.broadcasts.each {|x| x.save}
          end
          return false
        end
      end



      #protected

      def load_persistent_objects(t1=Time.now)
        def load_broadcasts(t1, activeness)
          Kernel::Broadcast.find_greater_than(t1, {:active => activeness}).map do |bc|
            case bc.attributes["type"]
            when "Original" then RadiaSource::LightWeight::Original.new_from_persistent_object(bc)
            when "Repetition" then RadiaSource::LightWeight::Repetition.new_from_persistent_object(bc)
            else RadiaSource::LightWeight::Broadcast.new_from_persistent_object(bc)
            end
          end
        end

        @inactive_broadcasts = load_broadcasts(t1, false)
        @broadcasts = load_broadcasts(t1, true)
        #@conflicts = Kernel::Conflict.all.map {|c| Conflict.new_from_persistent_object(c) }
        @timeframes = []
      end

    end


  
  end
end
