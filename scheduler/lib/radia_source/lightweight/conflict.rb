module RadiaSource
  module LightWeight

    class Conflict < ARProxy

      attr_accessor :active_broadcast, :new_broadcasts

      def initialize(args={})
        super()
        @new_broadcasts = args.has_key?(:new_broadcasts) ? args[:new_broadcasts] : []
        @active_broadcast = args.has_key?(:active_broadcast) ? args[:active_broadcast] : nil
      end

      def intersects? broadcast
        # if 
        if @active_broadcast.nil?
          return @new_broadcasts.any? { |bc| bc.intersects?(broadcast) }
        end
        return @active_broadcast.intersects?(broadcast)
      end

      def add_new_broadcast bc
        @new_broadcasts << bc
      end

      # A conflict is only automatically solved in two cases:
      #  - the active broadcasts is the similar to the new one
      #  - if there is no active broadcast and there is only one
      #  new broadcast
      def solvable?
        if @new_broadcasts.length == 1
          if @active_broadcast.nil? 
            return true
          else
            return @active_broadcast.similar? @new_broadcasts[0]
          end
        end
       return false
      end

      # returns the broadcasts to be destroyed if the conflict
      # can be automatically solvable. if it cannot be solvable
      # it returns an empty list.
      def solved_to_destroy
        if not self.solvable? or @active_broadcast.nil?
          return []
        end
        
        return @new_broadcasts
      end

      def save
        if @po.nil?
          classname = self.class.name.split("::")[-1]
          ab = @active_broadcast.nil? ? nil : @active_broadcast.persistent_object
          @po = Kernel.const_get(classname.to_s).create(
                :active_broadcast => ab, 
                :new_broadcasts => @new_broadcasts.map{ |bc| bc.persistent_object } )
        end
        super()
      end

    end
  end
end
