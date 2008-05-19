class Emission < Broadcast
  belongs_to :program
  belongs_to :emission_type
  
  has_many :repetitions, :dependent => :destroy
  has_one :bloc, :as => :playable, :dependent => :destroy
  
  # Ensure presence of mandatory attributes
  validates_presence_of :program, :emission_type
    
  # Creates an array for params (to use the emission's date)
  def to_param
    param_array
  end
  
  # Tests if this emission has been changed from its original state
  def modified?
    !self.description.nil?
  end
  
  # Returns the emission's parent for process configuration
  def parent
    self.program
  end
  
  def bloc
    read_attribute(:bloc).nil? ? emission_type.bloc : read_attribute(:bloc)  
  end
  
  # Audio assets for this emission
  def audio_assets
    bloc.audio_assets
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.broadcast(:type => 'emission') do 
      xml.tag!(:id, self.id, :type => :integer)
      xml.tag!(:dtstart, self.dtstart, :type => :datetime)
      xml.tag!(:dtend, self.dtend, :type => :datetime)
      xml.tag!(:description, self.description, :type => :string)
      bloc.to_xml(:skip_instruct => true, :builder => xml)
    end
  end
  
  
  def gap?
    false
  end
end
