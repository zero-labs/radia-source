#!/usr/bin/ruby
#



require 'eventmachine'

module RSServer
	def post_init 
		puts "someone connected"
    p $server.broadcasts
	end

	def receive_data data
		puts "someone wants: #{data}."
		send_data "dummy"
		close_connection_after_writing
	end

	def unbind
		puts "someone gone"
	end

end

module PlayoutScheduler
    def self.run(config)
        $server = PlayoutServer.new(config)
        EventMachine::start_unix_domain_server SocketFile,  RSServer
        Signal.trap("TERM") do
            require 'fileutils'
            EventMachine::stop_event_loop
            FileUtils::rm SocketFile
        end
    end
end

if $0.eql?( __FILE__ )
    p __FILE__
    EventMachine::run { PlayoutScheduler::run $playout_config }
end

#EOF
#
