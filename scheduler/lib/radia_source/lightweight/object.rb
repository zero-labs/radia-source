module RadiaSource
  module LightWeight
    module Object

      def self.included(base); 
        base.extend ClassMethods
      end

      module ClassMethods

        def proxy_reader(*args)
          begin
            self.instance_attributes.nil?
          ensure
            self.instance_attributes = []
          end
          args.each do |a|
            self.instance_attributes << a unless self.instance_attributes.find a
            self.send :define_method, a do 
              if @po.nil?
                @attributes[a]
              else
                  @po.send a
              end
            end
          end
        end

        def proxy_writer(*args)
          args.each do |a|
            method_name = (a.id2name + "=").to_sym
            send :define_method, method_name do |method_arg|
              if @po.nil?
                @attributes[a] = method_arg
              else
                @po.send method_name, method_arg
              end
            end
          end
        end

        def proxy_accessor(*args)
          proxy_reader(*args)
          proxy_writer(*args)
        end

      end

    end
  end
end

