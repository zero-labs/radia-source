module  PlayoutScheduler
    class Single
        def initialize uid
            @uid = uid
        end
        
        def self.load_from_scheduler asset
            @uid = asset.id
        end

    end

    class Playlist
        def initialize uri
            p uri
        end
    end
end
