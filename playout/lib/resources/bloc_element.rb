class BlocElement < ActiveResource::Base
  self.site = '' # TODO
  
  def to_palinsesto(builder, description, dtstart, dtend)
    asset = asset_instance(audio.attributes['type'])
    asset.load(audio.attributes)
    asset.to_palinsesto(builder, dtstart, dtend, description)
    
    #if fill?
    #  asset.to_palinsesto(builder)
    #else
    #end
  end
  
  
  protected
  
  def asset_instance(type)
    case type
    when 'single'
      Single.new
    when 'playlist'
      Playlist.new
    end
  end
end