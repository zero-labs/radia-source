module RadiaSource
  module LightWeight

    class Original < Broadcast

      attr_accessor :program
      def initialize(args=nil)
        super(args)
        unless args.nil?
          @program = args[:program]
          @structure_template = args[:structure_template]
        end
      end

      def program
        return po.nil? ? @program : @po.program
      end

      def program= x
        if @po.nil?
          return @program = x
        end
        return @po.program = x
      end

      def structure_template
        return po.nil? ? @structure_template : @po.structure_template
      end

      def structure_template= x
        if @po.nil?
          return @structure_template = x
        end
        return @po.structure_template = x
      end

      def similar? bc
        return false unless bc.kind_of? self.class
        super(bc) and @program == bc.program and @structure_template == bc.structure_template
      end

      def save
        super do
          if @po.nil?
            @po = create_persistent_object(
              :program_schedule => Kernel::ProgramSchedule.active_instance,
              :dtstart => @dtstart, 
              :dtend => @dtend,
              :program => @program,
              :structure_template => @structure_template )
          end
        end
      end

      def po!
        if @po.nil?
          @po = create_persistent_object(
            :program_schedule => Kernel::ProgramSchedule.active_instance,
            :dtstart => @dtstart, 
            :dtend => @dtend,
            :program => @program,
            :structure_template => @structure_template )
        end
        @po
      end 

    end

    
  #module ends here 
  end 
end

