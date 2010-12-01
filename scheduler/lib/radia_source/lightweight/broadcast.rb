module RadiaSource
  module LightWeight

    class Broadcast < ARProxy
      attr_accessor :dtstart, :dtend

      ### Instance methods

      def initialize args=nil
        super()
        unless args.nil?
          @dtend = args[:dtend]
          @dtstart = args[:dtstart]
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
        return false unless bc.kind_of? self.class
        dtstart == bc.dtstart and dtend == bc.dtend 
      end

      # proxy methods

      def activate
        if @po.nil?
          return nil
        end
        @po.activate
      end

      def save(&b)
        unless b.nil?
          return super(&b)
        else
          super() do
            if @po.nil?
              @po = create_persistent_object(
                :program_schedule => Kernel::ProgramSchedule.active_instance,
                :dtstart => @dtstart, 
                :dtend => @dtend )
            end
          end
        end
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


    end
  end
end
