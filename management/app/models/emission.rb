class Emission < Broadcast
  belongs_to :program
  belongs_to :emission_type
  
  has_many :repetitions, :dependent => :destroy
  has_one :bloc, :as => :playable, :dependent => :destroy
  
  # Ensure presence of mandatory attributes
  validates_presence_of :program, :emission_type
  
  # Callback to force the creation of a Bloc for this emission,
  # based on the Bloc of its EmissionType
  after_create :init_bloc
  
  # Returns false
  def gap?
    false
  end
  
  # Tests if this emission has been changed from its original state
  def modified?
    bloc.modified?
  end
  
  # Audio assets for this emission
  def audio_assets
    bloc.audio_assets
  end
  
  def authors
    program.authors
  end
  
  def update_bloc
    self.bloc.destroy unless self.bloc.nil?
    init_bloc
  end
  
  def deliver_single(params)
    self.bloc.update_single(params)
  end
  
  def status
    self.bloc.status
  end
  
  def name
    self.program.name
  end
  
  def pretty_print_status
    case status
    when :available
      'Available'
    when :delivered
      'Delivered'
    when :partial
      'Partially delivered'
    when :pending
      'Pending'
    end  
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    options[:replace_unavailable] ||= false
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.broadcast(:type => 'emission') do 
      xml.tag!(:id, self.id, :type => :integer)
      xml.tag!('program-id', self.program.urlname, :type => :string)
      xml.tag!(:dtstart, self.dtstart, :type => :datetime)
      xml.tag!(:dtend, self.dtend, :type => :datetime)
      xml.tag!(:description, self.description, :type => :string)
      bloc.to_xml(:skip_instruct => true, :builder => xml, :replace_unavailable => options[:replace_unavailable])
    end
  end
  
  protected
  
  def init_bloc
    self.bloc = Bloc.create(:playable => self)
    emission_type.bloc.segments.each do |e| 
      segment = e.clone
      asset = (e.audio_asset.kind != :playlist ? e.audio_asset.clone : e.audio_asset)
      asset.save
      segment.audio_asset = asset 
      #asset.segments << segment
      self.bloc.add_segment(segment)
    end
  end
end
