module RadiaSource
  module LightWeight

    class Broadcast < ARProxy
      proxy_accessor :dtstart, :dtend, :active

      #set_proxy_class Kernel::Broadcast

      ### Instance methods

      def initialize(args={})
        super({:active => false}.update(args))
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

      def dirty?
        # only database objects can actually be dirty:
        # before saving, every object is kind of virgin
        if @po.nil?
          return false
        end
        return @po.dirty?
      end

      def create_persistent_object(args={})
        args.update(:dtstart => dtstart, :dtend => dtend, :active => active,
                    :program_schedule => Kernel::ProgramSchedule.active_instance)
        super(args)
      end

    end
  end
end
