
module RadiaSource
  module LightWeight


    class TimeFrame
      
      attr_accessor :broadcasts 

      def self.merge nframe, frames
        frames.each do |fr|
          fr.broadcasts.each {|bc| nframe.add_broadcast! bc }
        end
        #nframe.update_borders!
        nframe
      end

      def initialize(params={})
        if params.has_key? :broadcast
          broadcast = params[:broadcast]
          @broadcasts = [broadcast]
          @dtstart = broadcast.dtstart
          @dtend = broadcast.dtend
        else
          @broadcasts = []
          @dtstart = nil
          @dtend = nil
        end
      end

      def intersects? broadcast
        return broadcasts.any? { |bc| broadcast.intersects?(bc) }
      end

      # The exclamation point means:
      #  - direct class variables are being used (instead of their accessor 
      #  method)
      #
      def add_broadcast! broadcast
        unless @broadcasts.any?{|x| x.similar? broadcast }
          @broadcasts << broadcast
          if not @dtstart.nil? and broadcast.dtstart < @dtstart
            @dtstart = broadcast.dtstart
          end
          if not @dtend.nil? and broadcast.dtend > @dtend
            @dtend = broadcast.dtend
          end
        end
        @broadcasts
      end


    end

  end
end
