class Playlist < AudioAsset
  include RadiaSource::AudioAssetGroup
  
  # The same playlist may belong to different blocs
  has_many :bloc_elements, :as => :bloc_elementable
  has_many :blocs, :through => :bloc_elements
  
  # A playlist is an ordered list of audio assets. 
  # Audio assets may belong to many playlists (thus the join model)
  has_many :playlist_elements, :order => :position
  has_many :audio_assets, :through => :playlist_elements
  
  def asset_name
    'Playlist'
  end
  
  def flatten
    self.audio_assets.collect { |a| a.single? ? a : a.flatten }
  end
  
  protected
  
  def assets_have_been_delivered
    
  end
end
