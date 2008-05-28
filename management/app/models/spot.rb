class Spot < AudioAsset
  include RadiaSource::SingleAudioAsset
  
  acts_as_single_asset
  
  def asset_name
    'Spot'
  end
  
end
