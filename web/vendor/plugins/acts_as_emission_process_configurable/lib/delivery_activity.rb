require 'rubygems'

gem 'activerecord'
require 'active_record'

module RadiaSource
  module DeliveryActivity
  
    def self.included(mod)
      mod.extend(ClassMethods)
    end
  
    module ClassMethods
      def has_delivery
        # Delivery
        has_one :delivery_service, :class_name => "ServiceConfiguration", 
                :foreign_key => "process_configuration_id", :conditions => "attrname = 'delivery_service'"
        has_one :delivery_deadline, :class_name => "ActionConfiguration", 
                :foreign_key => "process_configuration_id", :conditions => "attrname = 'delivery_deadline'"

        include RadiaSource::DeliveryActivity::InstanceMethods
      end
    end
  
    module InstanceMethods
      def delivery_service_field=(hsh) 
        self.delivery_service.update_attributes(hsh)
      end

      def delivery_deadline_field=(hsh)
        hsh[:string_value] = hsh[:string_value].join(' ')
        self.delivery_deadline.update_attributes(hsh)
      end

      protected

      def delivery_fields
        { :deadline => [:action, "Deadline", "Activate delivery deadline?", :string_value, "When?", 
                        [['minutes', 'hours', 'days'], ['before', 'after']]],
          :service => [:service, "Where should emissions be retrieved?"]}
      end

      def init_delivery
        self.delivery_service = ServiceConfiguration.create(:process_configuration => self,
                                                            :activity => 'Delivery', 
                                                            :protocol => 'ftp', 
                                                            :location => 'localhost',
                                                            :attrname => 'delivery_service')
        self.delivery_deadline = ActionConfiguration.create(:process_configuration => self,
                                                            :activity => 'Delivery',
                                                            :perform => true,
                                                            :string_value => "3 hours before", 
                                                            :attrname => 'delivery_deadline')
      end
    end
  end
end