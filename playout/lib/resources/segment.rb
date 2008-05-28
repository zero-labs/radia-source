class Segment < ActiveResource::Base
  
  self.site = '' # TODO
  
  def to_palinsesto(builder, description, dtstart, dtend)
    asset = asset_instance(audio)
    asset.to_palinsesto(builder, dtstart, dtend, description)
    
    #if fill?
    #  asset.to_palinsesto(builder)
    #else
    #end
  end
  
  protected
  
  def asset_instance(audio)
    asset = case audio.attributes['type']
    when 'single'
      Single.new
    when 'live' 
      Single.new
    when 'playlist'
      Playlist.find(audio.attributes['id'])
    end
    asset.load(audio.attributes)
  end
end