module PlayoutScheduler
    class Gap
        def self.new_gap_broadcast dtstart, dtend, *args
            if dtstart.eql?(dtend)
                nil
            end
            Broadcast.new("gap", :gap, dtstart, dtend, [
                          Segment.new(:Playlist, "/playlists/tna.m3u", dtend-dtstart)])
        end

        def self.new_gap_structure dtstart, dtend,*args
            [Segment.new(:Playlist, "/playlists/tna.m3u", dtend-dtstart)]
        end
    end
end
