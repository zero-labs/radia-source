    class Time
        def to_s
            #sprintf("%4d-%02d-%02d %02d:%02d:%02d", @year, @month, @day, @hour, @min, @sec) 
            strftime("%Y-%m-%d %H:%M:%S")
        end
    end
module PlayoutScheduler
    require 'rubygems'
    require 'dm-core'
    require 'assets'
    require 'gap'
    require 'scheduler'
    require 'update_service'
    require 'asset-manager'

    DataMapper.setup(:default, 'sqlite3::memory:')
    SocketFile = "/tmp/rs-playout.sock"
    DEBUG = 1
    #playout_config = {:yaml => File.open("/tmp/schedule_1.yml")}
    $playout_config = {'scheduler_uri' => "http://welles.radiozero.pt:3000"}
    DataMapper.auto_migrate!

end
