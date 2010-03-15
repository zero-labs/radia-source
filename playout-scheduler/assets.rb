module  PlayoutScheduler

    class Single
        include DataMapper::Resource

        property :id, Integer, :key => true
        property :retrieval_uri, String
        property :length, Float


        
        def self.load_from_scheduler asset
                p 123234214
            begin
                a = Single.get!(asset.id)
            rescue DataMapper::ObjectNotFoundError
                a = Single.new(:id => asset.id)
            end
            return a
        end

    end

    class Playlist
        def initialize uid
            @uid = uid
        end
    end
end
