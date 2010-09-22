module RadiaSource
  module LightWeight

    class PersistLayer
      
      # ar means ActiveRecord
      def self.from_ar(bc)
        n = self.new()
        n.po= bc
        return n
      end

      def initialize(args=nil)

        # po: two letters meaning persistent object
        if args.nil?
          @po = nil
        else
          @po = args          
        end
      end

      def save
        unless @po.nil?
          return @po.save
        end
        return false
      end
      
      def destroy
        unless po.nil?
          @po.destroy
        end
      end

      def get_persistent_object; 
        @po; 
      end
      alias :po                :get_persistent_object 
      alias :persistent_object :get_persistent_object 
      
      def set_persistent_object x
        @po = x
      end
      alias :po=                :set_persistent_object 
      alias :persistent_object= :set_persistent_object 
      
    end

    class ProgramSchedule
      include Singleton

      attr_accessor :broadcasts, :conflicts

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

        # unless somebody used them
        tmp = tmp.select { |bc| bc.dirty? }.each do |bc|
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
          @conflicts << params[:conflict]
        else
          @conflicts << Conflict.new(params)
        end
      end

    end

    class Conflict < PersistLayer

      attr_accessor :active_broadcast, :new_broadcasts

      def initialize(args={})
        super()
        @new_broadcasts = args.has_key?(:new_broadcasts) ? args[:new_broadcasts] : []
        @active_broadcast = args.has_key?(:active_broadcast) ? args[:active_broadcast] : nil
      end

      def intersects? broadcast
        # if 
        if @active_broadcast.nil?
          return @new_broadcasts.any? { |bc| bc.intersects?(broadcast) }
        end
        return @active_broadcast.intersects?(broadcast)
      end

      def add_new_broadcast bc
        @new_broadcasts << bc
      end

      # A conflict is only automatically solved in two cases:
      #  - the active broadcasts is the similar to the new one
      #  - if there is no active broadcast and there is only one
      #  new broadcast
      def solvable?
        if @new_broadcasts.length == 1
          if @active_broadcast.nil? 
            return true
          else
            return @active_broadcast.similar? @new_broadcasts[0]
          end
        end
       return false
      end

      # returns the broadcasts to be destroyed if the conflict
      # can be automatically solvable. if it cannot be solvable
      # it returns an empty list.
      def solved_to_destroy
        if not self.solvable? or @active_broadcast.nil?
          return []
        end
        
        return @new_broadcasts
      end

      def save
        if @po.nil?
          classname = self.class.name.split("::")[-1]
          ab = @active_broadcast.nil? ? nil : @active_broadcast.persistent_object
          @po = Kernel.const_get(classname.to_s).create(
                :active_broadcast => ab, 
                :new_broadcasts => @new_broadcasts.map{ |bc| bc.persistent_object } )
        end
        super()
      end

    end


    class Broadcast < PersistLayer
      attr_accessor :dtstart, :dtend, :program

      ### Instance methods

      def initialize args=nil
        super()
        unless args.nil?
          @dtend = args[:dtend]
          @dtstart = args[:dtstart]
          @program = args[:program]
          @structure_template = args[:structure_template]
        end
      end

      def intersects? bc
        if (dtstart < bc.dtstart and dtend > bc.dtstart) or
          (dtstart >= bc.dtstart and dtstart<bc.dtend)
          return true
        end
        return false
      end

      def similar? bc
        dtstart == bc.dtstart and dtend == bc.dtend and program == bc.program
      end

      # proxy methods

      def activate
        if @po.nil?
          return nil
        end
        @po.activate
      end

      def save
        if @po.nil?
          classname = self.class.name.split("::")[-1]
          @po = Kernel.const_get(classname.to_s).create(
                :program_schedule => Kernel::ProgramSchedule.active_instance,
                :program => @program,
                :structure_template => @structure_template,
                :dtstart => @dtstart, 
                :dtend => @dtend )
        end
        super()
      end
      def dirty?
        if @po.nil?
          return false
        end
        return po.dirty?
      end

      def dtstart
        if @po.nil?
          return @dtstart
        end
        return @po.dtstart
      end

      def dtstart= x
        if @po.nil?
          return @dtstart = x
        end
        return @po.dtstart = x
      end
          
      def dtend
        if @po.nil?
          return @dtend
        end
        return @po.dtend
      end

      def dtend= x
        if @po.nil?
          return @dtend = x
        end
        return @po.dtend = x
      end

      def program
        if @po.nil?
          return @program
        end
        return @po.program
      end

      def program= x
        if @po.nil?
          return @program = x
        end
        return @po.program = x
      end


      def structure_template
        if @po.nil?
          return @structure_template
        end
        return @po.structure_template
      end

      def structure_template= x
        if @po.nil?
          return @structure_template = x
        end
        return @po.structure_template = x
      end

    end

    class Original < Broadcast
    end

  end
end
