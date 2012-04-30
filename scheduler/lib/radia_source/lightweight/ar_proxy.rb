
path = File.dirname(__FILE__)
require "#{path}/ar_methods"
require "#{path}/object"

module RadiaSource
  module LightWeight

    class ProxyClassUndefined < Exception
    end

    # This class is used as a proxy to the fat ActiveRecord Models
    # We need this to avoid using the AR models during the import process
    # Implements the followingmethods: save & destroy

    # po: two letters meaning persistent object
    
    class ARProxy
      class << self
        attr_accessor :instance_attributes;
        attr_writer :proxy_class 
      end

      # for some reason this initialization isn't doing anything. So some
      # hacking is done on initialization instance method
      @instance_attributes = []
      @proxy_class = nil

      include RadiaSource::LightWeight::Object
      include RadiaSource::LightWeight::ActiveRecordMethods
      
      def self.new_from_persistent_object(bc)
        n = self.new()
        n.po= bc
        self.set_proxy_class bc.class
        return n
      end

      def self.set_proxy_class klass=nil
        return unless @proxy_class.nil?
        if klass.nil? then
          k = Kernel.const_get(self.name.split("::")[-1])
        else
          k = klass 
        end
        self.proxy_class =  k
      end

      #def self.proxy_class
      #  return @@proxy_class unless @@proxy_class.nil?
      #  self.set_proxy_class
      #end

      def self.method_missing method_id, *args
        if method_id == :proxy_class
          self.set_proxy_class

          # runtime definition of the "proxy_class" class method
          # at class "class instance" scope
          self.instance_eval { def proxy_class; @proxy_class;end}
          return self.proxy_class
        else
          super
        end
      end

      def initialize(args={})
        #for some reason, @instance_attributes class variable (class instance
        #variable scope) isn't being correctly initializated. So hacking is
        #needed.

        if self.class.instance_attributes.nil?
          self.class.instance_attributes = []
        end
        @attributes = args

        self.class.instance_attributes.each do |at| 
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


      def create_persistent_object(args={})
        ar_attributes = {}
        @attributes.each do |key,val|
          if val.kind_of?(ARProxy)
            ar_attributes[key] = val.po!
          else
            ar_attributes[key] = val
          end
        end

        self.class.set_proxy_class() if self.class.proxy_class.nil?
        raise ProxyClassUndefined.new if self.class.proxy_class.nil?
        self.class.proxy_class.create!(ar_attributes.merge(args))
      end
      
      def po!
        if @po.nil?
          @po = create_persistent_object()
        else
          @po
        end
      end 
        
    end
  
  end
end
