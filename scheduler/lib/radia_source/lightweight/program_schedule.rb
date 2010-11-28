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

        tmp = @to_destroy.find {|broadcast| bc.similar? broadcast}
        unless tmp.nil?
          # POTENTIAL BUG! Should test kind_of? ActiveRecord::Base
          # before assigment. Yet to_destroy list is constructed from
          # dirty broadcasts that should allways be AR )

          bc.persistent_object = tmp.persistent_object
          @to_destroy.delete(tmp)
        end

        @broadcasts << bc
        bc
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
          Broadcast.from_ar(bc)
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
