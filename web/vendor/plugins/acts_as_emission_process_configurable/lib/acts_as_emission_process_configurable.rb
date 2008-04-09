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
      
      # class level manipulations
      module ClassMethods
        def acts_as_emission_process_configurable(options = {})
          defaults = { :recorded => false, :live => false, :playlist => false, :repeat => false }
          
          defaults.merge(options).each do |key, val|
            case key
            when :recorded
              if val then 
                has_one(:recorded_process_configuration, :as => :processable)
                include RadiaSource::Acts::EmissionProcessConfigurable::RecordedInstanceMethods
              end
            when :live
              if val then 
                has_one(:live_process_configuration, :as => :processable)
                include RadiaSource::Acts::EmissionProcessConfigurable::LiveInstanceMethods
              end
            when :playlist
              if val then 
                has_one(:playlist_process_configuration, :as => :processable)
                include RadiaSource::Acts::EmissionProcessConfigurable::PlaylistInstanceMethods
              end
            when :repeat
              if val then 
                has_one(:repeat_process_configuration, :as => :processable)
                include RadiaSource::Acts::EmissionProcessConfigurable::RepeatInstanceMethods
              end
            end
          end
                    
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
      end
      
      module RecordedInstanceMethods  
        def recorded
          if self.parent.nil? and self.recorded_process_configuration.nil?
            init_recorded
          elsif self.recorded_process_configuration.nil?
            self.parent.recorded_process_configuration
          else
            self.recorded_process_configuration
          end
        end
        
        private
        
        def init_recorded
          self.recorded_process_configuration = RecordedProcessConfiguration.create(:processable => self)
          self.recorded_process_configuration.init_fields
          self.recorded_process_configuration.save
          self.recorded_process_configuration
        end
      end
      
      module LiveInstanceMethods
      end
      
      module PlaylistInstanceMethods
      end
      
      module RepeatInstanceMethods
      end
    end
  end
end

