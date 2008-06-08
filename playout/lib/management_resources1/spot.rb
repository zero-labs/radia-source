module ManagementResources

  class Spot < ActiveResource::Base
    self.site = "#{$playout_config['base_uri']}/audio/"
    
    # Flags a SpotAudioAsset as being downloaded
    def start_download
      s = SpotAudioAsset.find_or_create_by_id_at_source(self.id)

      if !retrieval_uri.nil? and s.status != 'downloading'
        s.status = 'downloading'
        s.save
      else
        false
      end
    end

    # Flags a SpotAudioAsset as not being downloaded (status = 'idle')
    def end_download
      s = SpotAudioAsset.find_or_create_by_id_at_source(self.id)
      s.status = 'idle'
      s.save
    end

    # Fetches the list of unavailable spots from the Management node
    def self.find_unavailable
      Spot.find :all, :from => :unavailable
    end
  end
  
end