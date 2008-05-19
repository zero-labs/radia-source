class Single < ActiveResource::Base
  self.site = 'http://localhost:3000/audio/'
  
  def asset_service
    AssetService.find(self.asset_service_id)
  end
  
  def fetch
    RAILS_DEFAULT_LOGGER.debug "--hello"
    SingleAudioAsset.find_or_create_by_id_at_source(self.id)
    if self.retrieval_uri.nil?
      RAILS_DEFAULT_LOGGER.debug "--message"
    end
  end
  
  def self.find_unavailable
    Single.find :all, :from => :unavailable
  end
end