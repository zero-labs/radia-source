class LiveSource < ActiveRecord::Base
  belongs_to :settings
  has_many :audio_assets
  
  validates_presence_of :title, :uri
end
