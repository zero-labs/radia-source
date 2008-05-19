class LiveSource < ActiveRecord::Base
  validates_presence_of :title, :url
  
  has_many :audio_assets
end
