class PlaylistElement < ActiveRecord::Base
  belongs_to :playlist
  belongs_to :audio_asset
  
  acts_as_list
end
