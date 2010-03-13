module PlayoutScheduler

    require 'monitor'
    require 'observer'


    class UpdateService
        include Observable

        UpdateServicePeriod = 30
        def initialize(server)
            @timer = nil
            @lock = Monitor.new
            
            @server = server
        end

        def start(block)
            @timer = EventMachine::PeriodicTimer.new(UpdateServicePeriod){ update_service(block) }
        end
        
        def update_service(block)
            return unless @lock.try_mon_enter()
            bcasts = PlayoutServer.load_from_scheduler()
            # Simulate loads long runs (debuging)
            #begin
            #        @first_time_dv.eql? true
            #rescue
            #        sleep 60 
            #ensure
            #        @first_time_dv=false
            #end
            #
            # Simulate load long runs (hardcore)

            x,y = 0,1
            1000000.times { x = x + y**2; y+=1 }
            #sleep(rand(120))

            #block.call(bcasts)
            @server.update(bcasts)
            @lock.mon_exit()
        end

        def debug(s)
            PlayoutScheduler::debug_log s
        end
    end
end
