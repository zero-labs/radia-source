class Repetition < Broadcast
  belongs_to :emission
  
  validates_presence_of :emission
  
  def program
    self.emission.program
  end
  
  def description
    self.emission.description
  end
  
  def modified?
    false
  end
  
  def bloc
    self.emission.bloc
  end
  
  def audio_assets
    self.emission.audio_assets
  end
  
  def to_broadcast(builder)
    self.emission.to_broadcast(builder)
  end
  
  def gap?
    false
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.broadcast(:type => 'repetition') do 
      xml.tag!(:id, self.id, :type => :integer)
      xml.tag!(:dtstart, self.dtstart, :type => :datetime)
      xml.tag!(:dtend, self.dtend, :type => :datetime)
      xml.tag!(:description, self.description, :type => :string)
      self.bloc.to_xml(:skip_instruct => true, :builder => xml)
    end
  end
end
