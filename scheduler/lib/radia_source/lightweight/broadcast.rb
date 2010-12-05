module RadiaSource
  module LightWeight

    class Broadcast < ARProxy
      proxy_accessor :dtstart, :dtend

      ### Instance methods

      def initialize(args={})
        super(args)
      end

      def intersects? bc
        not (bc.dtend <= self.dtstart or bc.dtstart >= self.dtend)
        #if (dtstart < bc.dtstart and dtend > bc.dtstart) or
        #  (dtstart >= bc.dtstart and dtstart<bc.dtend)
        #  return true
        #end
        #return false
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

      def save
        @attributes[:program_schedule] = Kernel::ProgramSchedule.active_instance
        super()         
      end

      def dirty?
        # only database objects can actually be dirty:
        # before saving, every object is kind of virgin
        if @po.nil?
          return false
        end
        return @po.dirty?
      end

    end
  end
end
