class Bloc < ActiveResource::Base
  # TODO self.site
  
  def to_broadcast(builder, name, dtstart, dtend)
    builder.description(name)
    builder.start(dtstart.strftime("%Y-%m-%d %H:%M"))
    builder.stop(dtend.strftime("%Y-%m-%d %H:%M"))
    builder.audio do
      audio_assets.each do |a|
        #a.to_broadcast(builder)
      end
    end
  end
  
  private
  
  def to_palinsesto(builder, name, dtstart, dtend)
    builder.Palinsesto do
      builder.Description(name)
      builder.Priority(1)
      builder.Start(dtstart.strftime("%Y-%m-%d %H:%M"))
      builder.Stop(dtend.strftime("%Y-%m-%d %H:%M"))
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
        builder.item()
      end
      builder.PathSpot()
    end
  end
end