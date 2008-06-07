class Spot < ActiveResource::Base
  self.site = "#{$playout_config['base_uri']}/audio/"
  
end