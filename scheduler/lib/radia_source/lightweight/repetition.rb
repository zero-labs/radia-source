module RadiaSource
  module LightWeight

    class Repetition < Broadcast

      attr_accessor :original
      def initialize args=nil
        super(args)
        @original = args[:original] unless args.nil?
      end

      def save
        super do
          puts "#{@original.object_id.to_s(16)},#{@original}, #{@dtstart}.."
          @po = create_persistent_object(
            :program_schedule => Kernel::ProgramSchedule.active_instance,
            :dtstart => @dtstart, 
            :dtend => @dtend,
            :original => @original.po!)
        end
      end

      def similar? bc
        return false unless bc.kind_of? self.class
        super(bc) and self.program == bc.program
      end

      def program
        @original.program
      end

      #def original
      #  return @original.po.nil? ? @original : @original.po
      #end

    end
  end
end
