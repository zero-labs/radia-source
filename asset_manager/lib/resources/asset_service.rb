class AssetService < ActiveResource::Base
  extend ServiceInterface::Ftp
  
  self.site = 'http://localhost:3000/settings/'
  
  def get(partial_location)
    case self.protocol
    when 'ftp'
      Ftp::get(self.uri + partial_location, self.login, self.password)
    end
  end
end

