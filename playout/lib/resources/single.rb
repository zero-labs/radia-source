class Single < ActiveResource::Base
  self.site = "#{$manager_config['base_uri']}/audio/"
  
  def asset_service
    AssetService.find(self.asset_service_id)
  end

  def fetch
    SingleAudioAsset.find_or_create_by_id_at_source(self.id)
    if self.retrieval_uri.nil?
    end
  end

  def self.find_unavailable
    Single.find :all, :from => :unavailable
  end


  def to_palinsesto(builder, dtstart, dtend, description)
    if self.attributes['type'] == 'single'
      single_to_palinsesto(builder, dtstart, dtend, description)
    elsif self.attributes['type'] == 'live'
      live_to_palinsesto(builder, dtstart, dtend, description)
    end
  end
  
  protected
  
  def live_to_palinsesto(builder, dtstart, dtend, description)
    builder.Palinsesto do
      builder.Description(description)
      builder.Priority(1)
      builder.Start(dtstart.getlocal.strftime("%Y-%m-%d %H:%M"))
      builder.Stop(dtend.getlocal.strftime("%Y-%m-%d %H:%M"))
      builder.TimeContinued(0)
      builder.SpotController(1)
      builder.Type('stream')
      builder.Jingle
      builder.PreSpot
      builder.PostSpot
      builder.Module
      builder.ModuleData
      builder.Stream(self.live_source)
      builder.RandomItem()
      builder.RandomSpot()
      builder.SoftStop(0)
      builder.RatioItem()
      builder.RatioSpot()
      builder.PathItem()
      builder.PathSpot()  
    end
  end
  
  def single_to_palinsesto(builder, dtstart, dtend, description)
    builder.Palinsesto do
      builder.Description(description)
      builder.Priority(1)
      builder.Start(dtstart.getlocal.strftime("%Y-%m-%d %H:%M"))
      builder.Stop(dtend.getlocal.strftime("%Y-%m-%d %H:%M"))
      builder.TimeContinued(0)
      builder.SpotController(1)
      builder.Type('files')
      builder.Jingle
      builder.PreSpot
      builder.PostSpot
      builder.Module
      builder.ModuleData
      builder.Stream
      builder.RandomItem()
      builder.RandomSpot()
      builder.SoftStop(0)
      builder.RatioItem()
      builder.RatioSpot()
      builder.PathItem do
        asset = SingleAudioAsset.find_by_id_at_source(self.id)
        builder.item(asset.location)
      end
      builder.PathSpot()
    end
  end
end