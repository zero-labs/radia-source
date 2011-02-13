module RadiaSource
  module LightWeight

    class Repetition < Broadcast

      proxy_accessor :original

      def initialize args={}
        super(args)
      end

      #def save
      #  super do
      #    puts "#{@original.object_id.to_s(16)},#{@original}, #{@dtstart}.."
      #    @po = create_persistent_object(
      #      :program_schedule => Kernel::ProgramSchedule.active_instance,
      #      :dtstart => @dtstart, 
      #      :dtend => @dtend,
      #      :original => @original.po!)
      #  end
      #end

      # this code might have some issues:
      # - a dirty repetition is one that points
      #   to a dirty original
      # - new (unsaved) repetions might point to 
      #   saved originals
      def dirty?
        if @po.nil?
          #if @original.nil? This should __never__ occur
          original.dirty?
        else
          @po.dirty?
        end
      end

      def similar? bc
        return false unless bc.kind_of? self.class
        if @po.nil?
          super(bc) and self.program == bc.program
        else
          @po.similar? bc
        end
      end

      def program
        original.program
      end

      def create_persistent_object args={}
        args.update :original => original.po!
        super args
      end

      def to_s
        "#{dtstart}-#{dtend} :: #{program.name}"
      end

    end
  end
end
