module PlayoutResources
  class Spot < ActiveResource::Base
    self.site = "#{$playout}/audio"
  end
end