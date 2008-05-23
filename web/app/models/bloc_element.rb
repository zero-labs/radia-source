class BlocElement < ActiveRecord::Base
  belongs_to :bloc
  belongs_to :audio_asset
  
  validates_presence_of :bloc
  validates_presence_of :audio_asset
      
  acts_as_list
    
  def name
    self.audio_asset.asset_name
  end  
  
  # For forms
  def asset=(value)
    self.send("#{value[:kind]}=".to_sym, value)
  end
  
  def audio_asset_id=(id)
    self.update_attributes(:audio_asset => AudioAsset.find(:id))
  end
  
  def length=(minutes)
    write_attribute(:length, minutes * ((@unit.nil? or (@unit == 'minutes')) ? 60 : 1)) unless minutes.nil?
  end
  
  def length
    if self.fill?
      bloc.nil? ? nil : bloc.playable_length
    else
      read_attribute(:length)
    end
  end
  
  def length_unit=(value)
    @unit = value
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.element do
      xml.tag!(:length, self.length, :type => :float)
      xml.tag!(:fill, self.fill, :type => :boolean)
      xml.tag!('items-to-play', self.items_to_play, :type => :integer)
      xml.tag!(:random, self.random, :type => :boolean)
      audio = \
      if ((audio_asset.nil? or !audio_asset.available?) and options[:replace_unavailable]) 
        AudioAsset.fill(self.length)
      else
        audio_asset
      end
      audio.to_xml(:skip_instruct => true, :builder => xml, :short => true)
    end
  end

  protected
  
  def single=(asset)
    if asset[:authored]
      params = authored_hash(asset)
      self.audio_asset = SingleAudioAsset.create(params)
    else
      self.audio_asset = SingleAudioAsset.find(asset[:id])
    end
  end
  
  def playlist=(asset)
    self.audio_asset = Playlist.find(asset[:id])
  end
  
  def live=(asset)
    if asset[:authored]
      params = authored_hash(asset)
    else
      params = authored_hash(asset).merge(:authored => false)
    end
    params.merge!(:live_source => LiveSource.find(asset[:live_source]))
    self.audio_asset = SingleAudioAsset.create(params)
  end
  
  def intermission=(asset)
    # TODO intermissions should be some sort of playlist
  end
  
  def get_deadline(string_array)
    string_array.join(' ')
  end
  
  def authored_hash(asset)
    params = { :authored => true, 
               :length => asset[:length], 
               :deadline => get_deadline(asset[:deadline]) }
  end
  
end
