class ProcessConfiguration < ActiveRecord::Base
  belongs_to :processable, :polymorphic => true
  has_many :activities
end
