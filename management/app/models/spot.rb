class Spot < AudioAsset
  include RadiaSource::SingleAudioAsset
  
  acts_as_single_asset
  
  def asset_name
    'Spot'
  end
  
  def available?
    begin
      s = PlayoutResources::Spot.find(self.id)
      s.available?
    rescue ActiveResource::ResourceNotFound
      false
    rescue Exception
      nil
    end
  end
  
end
