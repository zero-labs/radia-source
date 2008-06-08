module ManagementResources

  class PlaylistElement < ActiveResource::Base
    self.site = '' # TODO

    def to_palinsesto(builder)
      asset = SingleAudioAsset.find_by_id_at_source(single.id)
      builder.item(asset.location)
    end
  end
  
end