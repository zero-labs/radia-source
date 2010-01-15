#!/usr/bin/ruby
#

require 'rubygems'
require 'eventmachine'

module Client
	def post_init
		send_data "next_track"
		@data = ""
	end

	def receive_data data
		@data << data
		puts "Next song: #{@data}."
	end
	
	def unbind
		puts "Over&Out"
		EventMachine::stop_event_loop
	end
end


EventMachine::run {
	EventMachine::connect_unix_domain("/tmp/rs-playout.sock", Client)
}

exit 0

#EOF
#
