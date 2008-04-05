class ServiceConfiguration < ActiveRecord::Base
  validates_presence_of :protocol, :location, :activity
end
