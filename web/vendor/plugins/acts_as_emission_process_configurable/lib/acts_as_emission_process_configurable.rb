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
        def acts_as_emission_processable
          # this is at the class level
          # add any class level manipulations you need here, like has_many, etc.
          has_one :recorded_process_configuration, :as => :processable
          #has_one :live_process_configuration, :as => :processable
          
          
          extend RadiaSource::Acts::EmissionProcessConfigurable::SingletonMethods
          include RadiaSource::Acts::EmissionProcessConfigurable::InstanceMethods
        end
      end

      # Adds a catch_chickens class method which finds
      # all records which have a 'chickens' field set
      # to true.
      module SingletonMethods
        #def catch_chickens
        #  find(:all, :conditions => ['chickens = ?', true])
        #end
        # etc...
      end

      # Adds instance methods.
      module InstanceMethods
        #def eat_chicken
        #  puts "Fox with ID #{self.id} just ate a chicken" 
        #end
      end

    end
  end
end

