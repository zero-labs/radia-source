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
  end
end

