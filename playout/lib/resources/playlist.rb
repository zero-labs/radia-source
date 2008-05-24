class Playlist < ActiveResource::Base
  self.site = "#{$manager_config['base_uri']}/audio/"
  
  def to_palinsesto(builder, dtstart, dtend, description)
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
        elements_to_palinsesto(builder)
      end
      builder.PathSpot()
    end
  end
  
  protected
  
  def elements_to_palinsesto(builder)
    playlist_elements.each { |e| e.to_palinsesto(builder) }
  end
end