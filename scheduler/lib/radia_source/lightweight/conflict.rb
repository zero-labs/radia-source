module RadiaSource
  module LightWeight

    class Conflict < ARProxy

      proxy_accessor :active_broadcast, :new_broadcasts

      def initialize(args={})
        default = {:new_broadcasts => [], :active_broadcast => nil }
        super(default.merge(args))
      end

      def intersects? broadcast
        if active_broadcast.nil?
          return new_broadcasts.any? { |bc|  broadcast.intersects?(bc) }
        end
        return active_broadcast.intersects?(broadcast)
      end

      def add_new_broadcast bc
        #puts "Real conflict #{bc}"

        #filters out any double event...
        unless new_broadcasts.any?{|x| x.similar?(bc)}
          new_broadcasts << bc
        end
        new_broadcasts
      end

      # A conflict is only automatically solved in two cases:
      #  - the active broadcast is the similar to the new one
      #  - if there is no active broadcast and there is only one
      #  new broadcast
      def solvable?
        if new_broadcasts.length == 1
          if active_broadcast.nil? 
            return true
          else
            return active_broadcast.similar? new_broadcasts[0]
          end
        else
          return false
        end
      end

      # returns the broadcasts to be destroyed if the conflict
      # can be automatically solvable. if it cannot be solvable
      # it returns an empty list.
      def solved_to_destroy
        if not self.solvable? or active_broadcast.nil?
          return []
        end
        
        return new_broadcasts
      end

      def create_persistent_object args={}
        args.update(:active_broadcast => active_broadcast.po!,
                    :new_broadcasts => new_broadcasts.map {|bc| bc.po!})
        super(args)
      end
    end

  end
end
