require 'rubygems'

gem 'activerecord'
require 'active_record'

module RadiaSource
  module Acts #:nodoc:
    module EmissionProcessConfigurable #:nodoc:

      def self.included(mod)
        mod.extend(ClassMethods)
      end

      # declare the class level helper methods which
      # will load the relevant instance methods
      # defined below when invoked
      module ClassMethods
        def acts_as_emission_process_configurable
          # class level manipulations
          
          has_one :recorded_process_configuration, :as => :processable
          #has_one :live_process_configuration, :as => :processable
          
          extend RadiaSource::Acts::EmissionProcessConfigurable::SingletonMethods
          include RadiaSource::Acts::EmissionProcessConfigurable::InstanceMethods
        end
      end

      # Methods that apply to the class
      module SingletonMethods
        # ...
      end

      # Adds instance methods.
      module InstanceMethods
        def has_process?(type)
          respond_to?("#{type}_process_configuration")
        end
        
        def recorded
          init_recorded if self.recorded_process_configuration(true).nil?
          self.recorded_process_configuration(true)
        end
        
        private
        
        def init_recorded
          self.recorded_process_configuration = RecordedProcessConfiguration.create(:processable => self)
          self.recorded_process_configuration.init_fields
          self.recorded_process_configuration.save
        end
      end

    end
  end
end

