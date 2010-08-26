class Segment < ActiveRecord::Base
  belongs_to :structure
  belongs_to :audio_asset
  
  validates_presence_of :structure
  validates_presence_of :audio_asset
  
  #validates_presence_of :length, :unless => :does_not_need_length_field
  
  acts_as_list
    
  def name
    self.audio_asset.asset_name || 'Untitled'
  end  
  
  # For forms
  def asset=(value)
    self.send("#{value[:kind]}=".to_sym, value)
  end
  
  def audio_asset_id=(id)
    self.update_attributes(:audio_asset => AudioAsset.find(:id))
  end
  
  def length=(minutes)
    #write_attribute(:length, minutes * (@unit.nil? or (@unit == 'minutes') ? 60 : 1)) unless minutes.nil?
    write_attribute(:length, minutes * 60)
  end
  
  def length
    if self.fill?
      structure.nil? ? nil : structure.playable_length
    elsif read_attribute(:length).nil?
      audio_asset.length
    else
      read_attribute(:length)
    end
  end
  
  def length_unit=(value)
    @unit = value
  end
  
  def available?
    audio_asset.available?
  end
  
  def delivered?
    audio_asset.delivered?
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.segment do
      xml.tag!(:length, self.length, :type => :float)
      xml.tag!(:fill, self.fill, :type => :boolean)
      xml.tag!('items-to-play', self.items_to_play, :type => :integer)
      xml.tag!(:random, self.random, :type => :boolean)
      audio_asset.to_xml(:skip_instruct => true, :builder => xml, :short => true)
    end
  end

  protected
  
  def does_not_need_length_field
    self.fill? or !self.audio_asset.single?
  end
  
  def single=(asset)
    if asset[:authored]
      params = authored_hash(asset)
      self.audio_asset = Single.create(params)
    else
      self.audio_asset = Single.find(asset[:id])
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
    self.audio_asset = Single.create(params)
  end
  
  def intermission=(asset)
    # TODO intermissions should be some sort of playlist
  end
  
  def get_deadline(string_array)
    string_array.join(' ')
  end
  
  def authored_hash(asset)
    params = { :authored => true, 
               :length => asset[:length] }
               # , :deadline => get_deadline(asset[:deadline])
  end
  
end
