class Playlist < AudioAsset
  include RadiaSource::AudioAssetGroup
  
  # A playlist is an ordered list of audio assets. 
  # Audio assets may belong to many playlists (thus the join model)
  has_many :playlist_elements, :order => :position
  has_many :audio_assets, :through => :playlist_elements
  
  #after_save :store_availability
  
  def asset_name
    'Playlist'
  end
  
  def flatten
    self.audio_assets.collect { |a| a.single? ? a : a.flatten }
  end
  
  def kind
    :playlist
  end
  
  def available?
    assets = flatten
    (assets.size != 0) and (assets.select { |a| !a.available? }.size == 0)
  end
  
  def length
    flatten.inject { |sum, e| sum + e.length }
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.audio(:type => 'playlist') do 
      xml.tag!(:id, self.id, :type => :integer)
      unless options[:short]
        playlist_elements.to_xml(:skip_instruct => true, :builder => xml)
      end
    end
  end
  
  protected
  
  def assets_have_been_delivered
    
  end
end
