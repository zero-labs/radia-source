class ProcessConfiguration < ActiveRecord::Base
  belongs_to :processable, :polymorphic => true
  
  has_many :service_configurations
  has_many :action_configurations
end
