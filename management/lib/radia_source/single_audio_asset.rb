module RadiaSource
  module SingleAudioAsset
    module ClassMethods
      
      def acts_as_single_asset
        validates_presence_of :length, :unless => :unavailable?
        validates_numericality_of :length, :allow_nil => true

        before_save :store_retrieval_uri
      end
      
      def find_all_unavailable
        find(:all, :conditions => ["available = ? AND retrieval_uri IS NOT NULL", false])
      end
    end

    module InstanceMethods
      def single?
        true
      end
      
      def asset_service_id=(value)
        @asset_service = AssetService.find(value)
      end

      def partial_retrieval_uri=(value)
        @partial_uri = value
      end
      
      # An asset is considered to be delivered if it is available at
      # the broadcast node or if an AssetService has been defined for it
      def delivered?
        self.available? or !self.asset_service.nil?
      end
      
      protected 

      def store_retrieval_uri
        if @asset_service and @partial_uri
          self.retrieval_uri = @asset_service.full_uri + '/' + @partial_uri
        end
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
