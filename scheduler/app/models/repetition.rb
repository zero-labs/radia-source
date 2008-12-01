class Repetition < Broadcast
  belongs_to :emission
  
  # This association is used as a short-hand 
  # to avoid going through Emissions to get the Program
  belongs_to :program 
  
  validates_presence_of :emission
  
  before_save :update_program
  
  def gap?
    false
  end
  
  def modified?
    false
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    options[:replace_unavailable] ||= false
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.broadcast(:type => 'repetition') do 
      xml.tag!(:id, self.id, :type => :integer)
      xml.tag!('program-id', self.program.urlname, :type => :string)
      xml.tag!(:dtstart, self.dtstart, :type => :datetime)
      xml.tag!(:dtend, self.dtend, :type => :datetime)
      xml.tag!(:description, self.description, :type => :string)
      bloc.to_xml(:skip_instruct => true, :builder => xml, 
                  :replace_unavailable => options[:replace_unavailable], :repetition => true)
    end
  end
  
  # Checks if the method is one of those that delegate to the Emission 
  # and forwards it to this Repetition's Emission
  # Methods are:
  # * bloc
  # * description
  # * audio_assets
  # * status
  # * pretty_print_status
  # * deliver_single
  def method_missing(method, *args)
    to_delegate = /bloc|description|audio_assets|status|pretty_print_status|deliver_single|authors|name/
    if method.to_s.match(to_delegate)
      emission.send(method, *args)
    else
      super
    end
  end
  
  protected
  
  def update_program
    self.program = self.emission.program
  end
end
