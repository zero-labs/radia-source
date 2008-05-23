class LiveSource < ActiveRecord::Base
  validates_presence_of :title, :uri
  
  has_many :audio_assets
end
