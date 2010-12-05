
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
      @@proxy_class = nil

      include RadiaSource::LightWeight::Object
      include RadiaSource::LightWeight::ActiveRecordMethods
      
      def self.new_from_persistent_object(bc)
        n = self.new()
        n.po= bc
        self.set_proxy_class bc.class
        return n
      end

      def self.set_proxy_class klass=nil
        if klass.nil? then
          @@proxy_class = Kernel.const_get(self.class.name.split("::")[-1])
        else
          @@proxy_class = klass 
        end
        @@proxy_class
      end

      def self.proxy_class
        return @@proxy_class unless @@proxy_class.nil?
        self.set_proxy_class
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
      
        
    end
  
  end
end
