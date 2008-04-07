class ServiceConfiguration < ActiveRecord::Base
  belongs_to :process_configuration
  
  validates_presence_of :protocol, :location, :activity, :process_configuration, :attrname
end
