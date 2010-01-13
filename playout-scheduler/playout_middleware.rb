
module PlayoutMiddleware
    require 'rubygems'
    require 'active_resource'

    class Schedule < ActiveResource::Base
        self.site = $playout_config['scheduler_uri'] << "/"
    end

    class Broadcast < ActiveResource::Base
        self.site = $playout_config['scheduler_uri'] << "/schedule"
    end

    def self.fetch
        Schedule::find(:one, :from => '/schedule.xml').broadcasts
    end
end
