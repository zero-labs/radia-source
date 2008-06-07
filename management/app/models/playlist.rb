class Playlist < AudioAsset
  include RadiaSource::AudioAssetGroup
  
  # A playlist is an ordered list of AudioAssets. 
  # Audio assets may belong to many playlists (thus the join model)
  has_many :playlist_elements, :order => :position
  has_many :audio_assets, :through => :playlist_elements
    
  # Returns the 'Playlist' string
  def asset_name
    'Playlist'
  end
  
  # Returns the :playlist symbol
  def kind
    :playlist
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.playlist do 
      xml.tag!(:id, self.id, :type => :integer)
      unless options[:short]
        playlist_elements.to_xml(:skip_instruct => true, :builder => xml, :short => true)
      end
    end
  end
end
