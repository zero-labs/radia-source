class Bloc < ActiveRecord::Base
  
  # Playables are anything that has a broadcast structure,
  # i.e. Broadcast (and sub-classes) and EmissionType
  belongs_to :playable, :polymorphic => true
  
  # BlocElements associate AudioAssets with Blocs, 
  # defining some broadcast properties for the bloc
  has_many :elements, :class_name => 'BlocElement', :order => :position, :dependent => :destroy
  
  #validates_size_of :elements_with_broadcast_length, :maximum => 1
  
  #validates_presence_of :playable, :on => :save
  attr_protected :elements
  
  # Checks if the bloc has been modified from its original state
  # Does this by traversing through the bloc's elements and checking
  # that authored AudioAssets have been delivered (if some has, then the
  # bloc is considered modified). 
  # Unauthored AudioAssets don't influence this result
  def modified?
    elements.collect { |e| e.audio_asset.authored? and e.audio_asset.delivered? }.include?(true) 
  end
  
  # Returns the length (in seconds) of the associated Playable entity:
  # * nil for EmissionType
  # * Integer for other Broadcasts 
  def playable_length
    playable.length
  end
  
  # Returns the length (in seconds) of the associated AudioAssets 
  # of this bloc's elements
  def bloc_length
    return nil if (elements.size == 1) and elements.first.length.nil?
    elements.inject { |sum, e| sum + e.length }
  end
  
  # Get audio assets for this bloc
  def audio_assets(authored_only = false)
    assets = elements.collect { |e| e.audio_asset }
    authored_only ? assets.select { |a| a.authored? } : assets
  end
  
  # There can only be one element with fill == true 
  # (to indicate it lasts the same as the broadcast)
  def add_element(element)
    if !element.fill? or (self.elements.size == 0)
      elements << element
      self.save
    else
      false
    end
  end
  
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.bloc do
      elements.to_xml(:skip_instruct => true, :builder => xml, 
                      :replace_unavailable => options[:replace_unavailable])
    end
  end
  
  def elements_with_broadcast_length
    self.elements.collect { |e| e.length.nil? }
  end
end
