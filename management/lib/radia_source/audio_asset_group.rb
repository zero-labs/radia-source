module RadiaSource
  module AudioAssetGroup
    
    module ClassMethods
    end

    module InstanceMethods
      
      # Returns false
      def single?
        false
      end

      # Returns an array of all AudioAssets as singles
      # It recursively flattens AudioAssets that are not singles.
      def flatten
        self.audio_assets.collect { |a| a.single? ? a : a.flatten }
      end

      # Tests if all elements are available
      def available?
        check_elements_for_compliance { |e| !e.available? }
      end

      # Tests if all elements have been delivered
      def delivered?
        check_elements_for_compliance { |e| !e.delivered? }
      end

      # Returns the sum of all elements' length
      def length
        flatten.inject(0) { |sum, e| sum + e.length }
      end
      
      protected

      # Checks if all AudioAssets comply to a given operation (hence the block parameter).
      # Returns false if there aren't any AudioAssets in this playlist or 
      # if any asset returns false on the given block.
      def check_elements_for_compliance(&block)
        assets = flatten
        (assets.size != 0) and (assets.select { |a| yield a }.size == 0)
      end
      
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
