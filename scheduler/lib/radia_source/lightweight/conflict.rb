module RadiaSource
  module LightWeight

    class Conflict < ARProxy

      proxy_accessor  :broadcasts

      def initialize(args={})
        default = {:broadcasts => []}
        super(default.merge(args))
      end

      def intersects? broadcast
        return broadcasts.any? { |bc| broadcast.intersects?(bc) }
      end

      def add_broadcast bc
        unless broadcasts.any?{|x| x.similar?(bc)}
          broadcasts << bc
        end
        broadcasts
      end

      def solvable?
        if broadcasts.length == 1
          return true
        else
          return false
        end
      end

      # returns the broadcasts to be destroyed if the conflict
      # can be automatically solvable. if it cannot be solvable
      # it returns an empty list.
      def solved_to_destroy
        if not self.solvable?
          return []
        end
        
        return broadcasts
      end

      def create_persistent_object args={}
        args.update(:broadcasts => broadcasts.map {|bc| bc.po!})
        super(args)
      end
    end

  end
end
