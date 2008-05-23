class Playlist < ActiveResource::Base
  self.site = "#{$manager_config['base_uri']}/audio/"
  
  def to_palinsesto(builder, dtstart, dtend, description)
    
  end
end