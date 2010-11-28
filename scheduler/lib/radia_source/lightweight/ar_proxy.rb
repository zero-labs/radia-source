module RadiaSource
  module LightWeight

    # This class is used as a proxy to the fat ActiveRecord Models
    # We need this to avoid using the AR models during the import process
    # Currently it only implements the save & destroy methods
    
    class ARProxy
      
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
  
  end
end
