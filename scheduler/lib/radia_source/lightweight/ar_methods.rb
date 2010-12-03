module RadiaSource
  module LightWeight
    module ActiveRecordMethods

      def self.included(base); 
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end

      #the implementation of the ActiveRecord API

      module ClassMethods; end

      module InstanceMethods
        def save!(&b)
          b.call unless b.nil?
          return @po.save! unless @po.nil?
          puts "Upss not saved! po must be nil..."  #DEBUG
          return false
        end

        def save(&b)
          begin
            self.save!(&b)
          rescue => e
            puts e
            return false
          end
          return true
        end

        def destroy
          @po.destroy unless po.nil?
        end
      end
   
   
    end
  end
end
