require 'rubygems'
require 'openwfe'

#
# adding some participants

module RadiaSource
  module Participants
    include OpenWFE::Participant
    
    class Delivery 
      include OpenWFE::LocalParticipant
      
      def consume(workitem)
        puts "delivery"
        workitem.delivered = 'y'
        reply_to_engine workitem
      end
    end

    class Validation
      include OpenWFE::LocalParticipant
      
      def consume(workitem)
        puts "validation"
        workitem.modified = 'y'
        reply_to_engine workitem
      end
    end

    class Broadcast
      include OpenWFE::LocalParticipant
      
      def consume(workitem)
        puts "broadcast"
        workitem.normal = 'y'
        reply_to_engine workitem
      end
    end

    class PostBroadcast
      include OpenWFE::LocalParticipant
      
      def consume(workitem)
        puts "post_broadcast"
        reply_to_engine workitem
      end
    end

    class Alternative
      include OpenWFE::LocalParticipant
      
      def consume(workitem)
        puts "alternative"
        reply_to_engine workitem
      end
    end

    class Alert
      include OpenWFE::LocalParticipant
      
      def consume(workitem)
        puts "alert"
        reply_to_engine workitem
      end
    end

    class Waiter
      include OpenWFE::LocalParticipant
      
      def consume(workitem)
        sleep 5
        puts "wait_for_decision"
        reply_to_engine workitem
      end
    end
  end
end