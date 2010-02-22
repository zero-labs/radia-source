module PlayoutScheduler

    require 'eventmachine'
    require 'monitor'
    class AssetManager
        def initialize log_file=STDERR
            @lock = Monitor.new
            @request_count = 0
            @pending_requests = []
            @logger = log_file

            debug("New Asset manager created")
            debug("Event Machine running? #{EventMachine::reactor_running?}," +
                  "(#{EventMachine.threadpool_size} threads)")
        end

        def request broadcast
            @lock.synchronize do 
                @pending_requests << broadcast
                start_broadcast_request if @request_count < 5
            end
        end

        protected

        def start_broadcast_request
            @request_count += 1
            debug("thread requested (req. cout->#{@request_count})")
            #op = proc { process_request }
            #req= proc { |x| end_broadcast_request(x) }
            #EventMachine::defer(process_request, end_broadcast_request)
            EventMachine::defer(lambda {process_request},
                                lambda { |x| end_broadcast_request(x)})

        end

        def process_request
            debug("processing started")

            bc = nil
            @lock.synchronize do
                bc = @pending_requests.shift
            end

            sleep(rand(5))
            debug("broadcast: #{bc}-")
            debug("processing ended")
        end

        def end_broadcast_request(x)
            @lock.synchronize do
                @request_count -= 1
                start_broadcast_request unless @pending_requests.empty?
            end
            debug("thread dismissed")
        end

        def debug s
            @logger.write("#{Time.now} - am(#{Thread.current}) - #{s}\n") if DEBUG
        end

    end
end

