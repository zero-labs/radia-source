
module PlayoutMiddleware
    require 'rubygems'
    require 'active_resource'

    def self.fetch
        Schedule::find(:one, :from => '/schedule.xml').broadcasts
    end

    class Schedule < ActiveResource::Base
        self.site = $playout_config['scheduler_uri'] << "/"
    end

    class Broadcast < ActiveResource::Base
        self.site = $playout_config['scheduler_uri'] << "/schedule"
    end

    class Bloc < ActiveResource::Base
        self.site = ''
    end

    class Segment < ActiveResource::Base
        self.site = ''
    end

    class Single < ActiveResource::Base
        self.site = $playout_config['scheduler_uri'] << "/audio/"
    end
end
