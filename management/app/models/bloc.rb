class Bloc < ActiveRecord::Base
  
  # Playables are anything that has a broadcast structure,
  # i.e. Broadcast (including its sub-classes) and EmissionType
  belongs_to :playable, :polymorphic => true
  
  # Segments associate AudioAssets with Blocs, 
  # defining the broadcast properties for the bloc
  has_many :segments, :order => :position, :dependent => :destroy
  
  #validates_size_of :segments_with_broadcast_length, :maximum => 1
  
  #validates_presence_of :playable, :on => :save
  attr_protected :segments
  
  # Checks if the bloc has been modified from its original state
  # Does this by traversing through the bloc's segments and checking
  # that authored AudioAssets have been delivered (if some has, then the
  # bloc is considered modified). 
  # Unauthored AudioAssets don't influence this result
  def modified?
    segments.collect { |e| e.audio_asset.authored? and e.audio_asset.delivered? }.include?(true) 
  end
  
  # Returns the length (in seconds) of the associated Playable entity:
  # * nil for EmissionType
  # * Integer for other Broadcasts 
  def playable_length
    playable.length
  end
  
  # Returns the length (in seconds) of the associated AudioAssets 
  # of this bloc's segments
  def bloc_length
    return nil if (segments.size == 1) and segments.first.length.nil?
    segments.inject { |sum, e| sum + e.length }
  end
  
  # Get audio assets for this bloc
  def audio_assets(authored_only = false)
    assets = segments.collect { |e| e.audio_asset }
    authored_only ? assets.select { |a| a.authored? } : assets
  end
  
  # Mass update for audio assets in this bloc (for forms)
  def audio_assets=(kollection)
    kollection.each do |params|
      asset = AudioAsset.find(params.id)
      next unless asset
      asset.update_attributes(params)
    end
  end
  
  def update_single(params)
    segment = self.segments.find(params[:segment])
    segment.audio_asset.update_attributes(params[:single])
  end
  
  # There can only be one element with fill == true 
  # (to indicate it lasts the same as the broadcast)
  def add_segment(segment)
    if !segment.fill? or (self.segments.size == 0)
      segments << segment
      self.save
    else
      false
    end
  end
  
  def status
    status_array = segments.collect { |s| s.delivered? }.select { |s| s }
    if status_array.size == 0
      :pending
    elsif status_array.size == segments.size
      av = segments.collect { |s| s.available? }.select { |s| s }
      if av.size == segments.size
        :available
      else
        :delivered
      end
    else
      :partial
    end
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    options[:repetition] ||= false
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.bloc do
      segments.to_xml(:skip_instruct => true, :builder => xml, 
                      :replace_unavailable => options[:replace_unavailable], 
                      :repetition => options[:repetition])
    end
  end
  
  def segments_with_broadcast_length
    self.segments.collect { |e| e.length.nil? }
  end
end
