class Bloc < ActiveRecord::Base
  
  # Playables are anything that has a broadcast structure (e.g., Emission, EmissionType)
  belongs_to :playable, :polymorphic => true
  
  # BlocElements associate AudioAssets with Blocs, defining some broadcast properties for the bloc
  has_many :elements, :class_name => 'BlocElement', :order => :position, :dependent => :destroy
  
  #validates_size_of :elements_with_broadcast_length, :maximum => 1
  
  #validates_presence_of :playable, :on => :save
  attr_protected :elements
    
  def playable_length
    self.playable.length
  end
  
  def bloc_length
    return nil if (self.elements.size == 1) and self.elements.first.length.nil?
    self.elements.inject { |sum, e| sum + e.length }
  end
  
  # Get audio assets for this bloc
  def audio_assets(authored_only = false)
    assets = self.elements.collect { |e| e.audio_asset }
    authored_only ? assets.select { |a| a.authored? } : assets
  end
  
  # There can only be one element with length == nil 
  # (to indicate it lasts the same as the broadcast)
  def add_element(element)
    if !element.length.nil? or (self.elements.size == 0)
      self.elements << element
      element
    else
      false
    end
  end
  
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.bloc do
      elements.to_xml(:skip_instruct => true, :builder => xml, :replace_unavailable => options[:replace_unavailable])
    end
  end
  
  def elements_with_broadcast_length
    self.elements.collect { |e| e.length.nil? }
  end
end
