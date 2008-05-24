class SingleAudioAsset < AudioAsset
  include RadiaSource::SingleAudioAsset
  
  belongs_to :asset_service
  belongs_to :live_source
  
  #validates_presence_of :location, :unless => :unknown
  #validates_presence_of :asset_service, :if => :needs_delivery
  
  validates_presence_of :length, :unless => :unavailable?
  validates_numericality_of :length, :allow_nil => true
  
  
  def asset_service_id=(value)
    self.asset_service = AssetService.find(value)
  end
  
  def live?
    !self.live_source.nil?
  end
  
  def self.find_all_unavailable
    find(:all, :conditions => ["available = ? AND asset_service_id IS NOT NULL", false])
  end
  
  def kind
    self.live_source.nil? ? :single : :live
  end
  
  def asset_name
    if kind == :live
      name = "Live"
    elsif kind == :single
      name = "Single"
    end
    name + " (#{self.authored? ? 'New by author' : 'Without author'})"
  end
  
  # An asset is considered to be delivered if it is available at
  # the broadcast node or if an AssetService has been defined for it
  def delivered?
    self.available? or !self.asset_service.nil?
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.audio(:type => kind) do
      xml.tag!(:id, self.id, :type => :integer)
      xml.tag!('live-source', self.live_source.uri, :type => :string) if kind == :live
      unless options[:short]
        xml.tag!(:authored, self.authored, :type => :boolean)
        xml.tag!(:available, self.available, :type => :boolean)
        xml.tag!(:deadline, self.deadline, :type => :string)
        xml.tag!(:length, self.length, :type => :float)
        val, opts = (self.asset_service.nil? ? ['', {:nil => true}] : [self.asset_service.full_uri, {}])
        xml.tag!('retrieval-uri', val, { :type => :string }.merge(opts))
      end
    end
  end
  
  protected 
  
  def needs_delivery
    self.authored? or !self.available?
  end
  
  def unknown
    self.authored? and self.unavailable?
  end
end
