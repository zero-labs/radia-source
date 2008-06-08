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
      
      def find_all_delivered_after(dtime)
        find(:all, :conditions => ["delivered_at >= ?", dtime], :order => "delivered_at DESC")
      end
      
      def find_recently_delivered(top = 5)
        find(:all, :conditions => "delivered_at IS NOT NULL", :order => "delivered_at DESC", :limit => top)
      end
    end

    module InstanceMethods
      
      # Returns true
      def single?
        true
      end
      
      def asset_service_id=(value)
        @asset_service = AssetService.find(value)
      end

      def partial_retrieval_uri=(value)
        @partial_uri = value
      end
      
      # An asset is considered to be delivered if has
      # delivered_at datetime != nil
      def delivered?
        !self.delivered_at.nil?
      end
      
      protected 

      def store_retrieval_uri
        if @asset_service and @partial_uri
          self.retrieval_uri = @asset_service.full_uri + '/' + @partial_uri
          self.delivered_at = Time.now
        end
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
