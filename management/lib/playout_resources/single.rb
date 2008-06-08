module PlayoutResources
  class Single < ActiveResource::Base
    self.site = "#{$playout}/audio"
  end
end