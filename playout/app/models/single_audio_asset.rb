class SingleAudioAsset < ActiveRecord::Base
  
  def to_param
    id_at_source
  end
end
