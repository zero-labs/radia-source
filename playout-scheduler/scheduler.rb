
module PlayoutScheduler
   
    require 'rubygems'
    require 'eventmachine'

    class Single
        def initialize uri
            p uri
        end
    end

    class Playlist
        def initialize uri
            p uri
        end
    end

    class Gap
        def self.new_gap_broadcast dtstart, dtend, *args
            Broadcast.new("gap", dtstart, dtend, [Segment.new(:Playlist, "tna.m3u", dtend-dtstart)])
        end

        def self.new_gap_structure dtstart, dtend,*args
            [Segment.new(:Playlist, "tna.m3u", dtend-dtstart)]
        end
    end

    class Segment
        def initialize type, uri, length
            @type = type
            if [:Single, :Playlist].include?(type)
                #@asset = eval(type + ".new(uri)")
                
                # Alternative to ugly eval:
                @asset =PlayoutScheduler.const_get(type).new(uri)
            else
                @asset = nil
            end
            @length= length
        end

        def self.load_from_scheduler seg
            type = seg.attributes["type"].to_sym
            PlayoutScheduler.const_get(type).new(uri)
        end
    end

    class Broadcast
        attr_reader :name, :type, :dtstart, :dtend, :structure
        attr_accessor :timer
        def initialize name, dtstart, dtend, structure = nil
            @name = name
            @dtstart = dtstart
            @dtend = dtend
            @structure = structure
            if @structure.nil?
                @active_segment = nil
            else
                @active_segment = @structure[0]
            end
        end

        def self.load_from_scheduler bc
                if !bc.respond_to?(:structure) or bc.structure.nil?
                    struct = Gap.new_gap_structure(bc.dtstart, bc.dtend)
                    Broadcast.new("gap", bc.dtstart, bc.dtend, struct)
                else
                    struct = broadcast[:structure].map do |segment|
                        Segment.load_from_scheduler(segment)
                    end
                end
                Broadcast.new(bc.description, bc.dtstart, bc.dtend, struct)
        end

        def to_s
            [@name,@dtstart,@dtend].join(", ")
        end
    end

    class PlayoutServer
        attr_reader :broadcasts
        def initialize init, broadcasts = []
            @broadcasts = broadcasts
            if init.key? :yaml then
                @broadcasts = load_yaml init[:yaml]
                @next_broadcast = get_next
                current_broadcast()
            elsif init.key? :scheduler_uri
                @broadcasts = load_from_scheduler 
                @next_broadcast = get_next
                current_broadcast()
            end
        end

        protected
        def load_yaml obj
            require 'yaml'
            broadcasts = []
            YAML::load( obj ).each do |broadcast|
                struct = broadcast["structure"].select do |segment|
                    Segment.new segment["type"].to_sym, segment["uri"], segment["length"]
                end
                broadcasts << Broadcast.new(broadcast["name"], broadcast["dtstart"], broadcast["dtend"], struct)
            end
            p broadcasts
            broadcasts
        end

        def load_from_scheduler
            require 'playout_middleware'
            PlayoutMiddleware::fetch.each do |broadcast|
                broadcasts << Broadcast.load_from_scheduler(broadcast)
            end
            p broadcasts
            broadcasts
        end
        def get_next bc=nil
            now = bc.nil? ? Time.now : bc.dtend
            next_broadcast = nil
            while next_broadcast.nil?
                if @broadcasts.empty? then
                    return nil
                end
                if @broadcasts[0].dtstart > now then
                     next_broadcast = Broadcast.new("gap", now, @broadcasts[0].dtstart)
                     p "Next track: gap" if DEBUG
                     break
                else
                    if @broadcasts[0].dtend > now
                        next_broadcast = @broadcasts.shift()
                        p "Next track: #{next_broadcast}" if DEBUG
                        break
                    else
                        @broadcasts.shift()
                    end
                end
            end
            next_broadcast
        end
        
        def current_broadcast 
            @current_broadcast = @next_broadcast
            p "Current broadcast: #{@current_broadcast}" if DEBUG
            @next_broadcast = get_next @current_broadcast
            if @current_broadcast.nil? then
                return
            end
            @current_broadcast.timer= EventMachine::Timer.new(@current_broadcast.dtend-Time.now) {current_broadcast()}
        end
    end
end



