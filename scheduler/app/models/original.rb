class Original < Broadcast
  belongs_to :program
  belongs_to :structure_template
  
  has_many :repetitions, :dependent => :destroy
  has_one :structure, :as => :playable, :dependent => :destroy
  
  # Ensure presence of mandatory attributes
  validates_presence_of :program, :structure_template
  
  # Callback to force the creation of a Structure for this emission,
  # based on the Structure of its StructureTemplate
  after_create :init_structure
  
  # Returns false
  def gap?
    false
  end
  
  # Tests if this emission has been changed from its original state:
  # Creation datetime different from update time OR
  # a description has been added OR
  # its structure has been modified (e.g. an audio asset has been delivered)
  def modified?
    (self.created_at != self.updated_at) || (description != nil) || (structure.modified?)
  end
  
  # Audio assets for this emission
  def audio_assets
    structure.audio_assets
  end
  
  # TODO change this to allow authorships on individual broadcasts
  def authors
    program.authors
  end
  
  def update_structure
    self.structure.destroy unless self.structure.nil?
    init_structure
  end
  
  def deliver_single(params)
    self.structure.update_single(params)
  end
  
  def status
    self.structure.status
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
      structure.to_xml(:skip_instruct => true, :builder => xml, :replace_unavailable => options[:replace_unavailable])
    end
  end
  
  protected
  
  def init_structure
    self.structure = Structure.create(:playable => self)
    structure_template.structure.segments.each do |e| 
      segment = e.clone
      asset = (e.audio_asset.kind != :playlist ? e.audio_asset.clone : e.audio_asset)
      asset.save
      segment.audio_asset = asset 
      #asset.segments << segment
      self.structure.add_segment(segment)
    end
  end
end
