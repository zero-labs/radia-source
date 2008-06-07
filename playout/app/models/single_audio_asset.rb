class SingleAudioAsset < AudioAsset
  
  def to_param
    id_at_source
  end
  
  def available?
    !self.location.nil?
  end
  
  def unavailable?
    !available?
  end
  
end
