
path = File.dirname(__FILE__)
require "#{path}/ar_methods"
require "#{path}/object"

module RadiaSource
  module LightWeight

    # This class is used as a proxy to the fat ActiveRecord Models
    # We need this to avoid using the AR models during the import process
    # Implements the followingmethods: save & destroy

    # po: two letters meaning persistent object
    
    class ARProxy
      @@instance_attributes = []

      include RadiaSource::LightWeight::Object
      include RadiaSource::LightWeight::ActiveRecordMethods
      
      def self.new_from_persistent_object(bc)
        n = self.new()
        n.po= bc
        return n
      end

      def initialize(args={})
        @attributes = args

        @@instance_attributes.each do |at| 
          @attributes[at] = nil unless @attributes.has_key?(at)
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
      
      def create_persistent_object(*arg)
          classname = self.class.name.split("::")[-1]
          Kernel.const_get(classname.to_s).create!(*arg)
      end
        
    end
  
  end
end
