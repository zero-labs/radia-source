module ManagementResources

  class Playlist < ActiveResource::Base
    self.site = "#{$playout_config['base_uri']}/audio/"

    def to_palinsesto(builder, position, total, dtstart, dtend, description)
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

    # Avoids problems when reloading because it doesn't
    # use the find method (that instantiates self and nested objects). 
    # Since the get method returns a vanilla Hash, we're good to go
    def alternative_reload
      self.load(self.class.get(id, :params => @prefix_options))
    end

    def elements_to_palinsesto(builder)
      if !respond_to?(:playlist_elements)
        alternative_reload
      end
      playlist_elements.each { |e| e.to_palinsesto(builder) }
    end
  end

end