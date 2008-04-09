require 'rubygems'

gem 'activerecord'
require 'active_record'

module RadiaSource
  module ValidationActivity
    
    def self.included(mod)
      mod.extend(ClassMethods)
    end
  
    module ClassMethods
      def has_validation
         # Validation
          has_one :validation_time_stretch, :class_name => "ActionConfiguration", 
                  :foreign_key => "process_configuration_id", :conditions => "attrname = 'validation_time_stretch'"
          has_one :validation_normalize, :class_name => "ActionConfiguration", 
                  :foreign_key => "process_configuration_id", :conditions => "attrname = 'validation_normalize'"
          has_one :validation_fade_out, :class_name => "ActionConfiguration",
                  :foreign_key => "process_configuration_id", :conditions => "attrname = 'validation_fade_out'"
          has_one :validation_playlist, :class_name => "ActionConfiguration", 
                  :foreign_key => "process_configuration_id", :conditions => "attrname => 'validation_playlist'"

          include RadiaSource::ValidationActivity::InstanceMethods
      end
    end
  
    module InstanceMethods
      def validation_time_stretch_field=(hsh)
        self.validation_time_stretch.update_attributes(hsh)
      end

      def validation_normalize_field=(hsh)
        self.validation_normalize.update_attributes(hsh)
      end

      def validation_fade_out_field=(hsh)
        self.validation_fade_out.update_attributes(hsh)
      end

      def validation_playlist_field=(hsh)
        self.validation_playlist.update_attributes(hsh)
      end

      protected

      def init_validation
        self.validation_time_stretch = ActionConfiguration.create(:process_configuration => self,
                                                                  :activity => 'Validation',
                                                                  :perform => true,
                                                                  :numerical_value => 4,
                                                                  :attrname => 'validation_time_stretch')
      end

      def validation_fields
        {:time_stretch => [:action, "Time-Stretch", "Time-stretch emission?", :numerical_value, "Percentage"]}
      end
    end
  end
end