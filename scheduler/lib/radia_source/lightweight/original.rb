module RadiaSource
  module LightWeight

    class Original < Broadcast

      proxy_accessor :program, :structure_template

      def initialize(args={})
        super args
      end

      def similar? bc
        return false unless bc.kind_of? self.class
        super(bc) and program == bc.program and structure_template == bc.structure_template
      end


      #def save
      #  super do
      #    if @po.nil?
      #      @po = create_persistent_object(
      #        :program_schedule => Kernel::ProgramSchedule.active_instance,
      #        :dtstart => @dtstart, 
      #        :dtend => @dtend,
      #        :program => @program,
      #        :structure_template => @structure_template )
      #    end
      #  end
      #end

    end

    
  #module ends here 
  end 
end

