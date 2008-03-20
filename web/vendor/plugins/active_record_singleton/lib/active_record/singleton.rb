module ActiveRecord#:nodoc:
  # Mixin to make an ActiveRecord class behave in a singleton fashion, having
  # only one row in its associated table.
  #
  # ActiveRecord::Singleton does not, by its nature, support STI (single table inheritance).
  #
  # A Singleton still has a primary key id column, for the following reasons:
  # * the ActiveRecord finders and updaters will work untouched, and
  # * so you can reference the singleton record from other classes (or if the singleton has a has_many relationship) in the usual way.
  #
  # The finders work as expected, but always return the same object (if one is found by the query).
  # 
  # You cannot call destroy on a singleton object
  #
  # You cannot instantiate a Singleton object with <tt>new</tt>, use <tt>instance</tt> or <tt>find</tt>
  #
  # ActiveRecord::Singleton is Thread safe, and handles concurrent access properly (if two separate processes
  # instantiate a Singleton where a table is empty, only one row will be created)
  # 
  # === Example of use:
  # <em>meta data on another active record</em>
  #
  #   class FocusableListItem < ActiveRecord::Base
  #     class Properties < ActiveRecord::Base
  #       inlcude ActiveRecord::Singleton
  #     end
  #   
  #     acts_as_list
  #   
  #     after_save do |record| # new record recieves focus
  #       Properties.instance.update_attributes :has_focus_id => record.id
  #     end
  #   
  #     def self.focused
  #       find Properties.instance.has_focus_id
  #     end
  #     
  #     def recieve_focus
  #       Properties.instance.update_attributes :has_focus_id => id
  #     end
  #   end
  module Singleton
    def self.included(base)
      require 'singleton'
      base.class_eval do
        include ::Singleton
        extend ClassMethods
        alias_method_chain :initialize, :singleton
        protected :destroy
       end
    end
    
    # initializing the instance finds the first (only) record, if the record does not exist
    # then one is created (without validation).  This happens within a transaction with a lock
    # to ensure that two different processes do not create two new singleton rows.
    def initialize_with_singleton(*args)
      initialize_without_singleton(*args)
      transaction do
        if attributes = self.class.read_singleton_attributes(:lock => true)
          instance_variable_set("@attributes", attributes)
          instance_variable_set("@new_record", false)
        else
          self.save(false)
        end
      end
    end
    
    module ClassMethods
      # returns a hash of attributes from the row, or nil if there is no row
      def read_singleton_attributes(options = {})
        connection.select_one("SELECT * FROM #{table_name} LIMIT 1 #{options[:lock] ? ' FOR UPDATE' : ''}")
      end
      
      # instantiating the record is now simply a matter of copying the record to the instance's attributes (no STI)
      def instantiate(record)
        instance.instance_variable_set("@attributes", record)
        instance
      end
    end
  end
end