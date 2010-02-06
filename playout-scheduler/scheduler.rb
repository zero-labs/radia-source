module PlayoutScheduler
   
    require 'rubygems'
    require 'eventmachine'
    require 'thread'



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
            if seg.respond_to? "single" then 
                type,asset = :Single, seg.send('single')
            else
                type,asset = :Playlist, seg.send('playlist')
            end
            PlayoutScheduler.const_get(type).send(:load_from_scheduler, asset)
        end

        def to_play
        end
    end

    class Broadcast
        attr_reader :name, :type, :dtstart, :dtend, :structure
        attr_accessor :timer
        def initialize name, type, dtstart, dtend, structure = nil
            @name = name
            @dtstart = dtstart
            @dtend = dtend
            @type = type
            @structure = structure
            if @structure.nil?
                @active_segment = nil
            else
                @active_segment = @structure[0]
            end
        end

        # Returns a string with the asset to be played
        def to_play
            return "" if @active_segment.nil?
            @active_segment.to_play 
        end

        # Conversion method:
        # - Receives: a PlayoutMiddleware::Broadcast
        # - Returns: PlayoutScheduler::Broadcast
        def self.load_from_scheduler bc
            type = case bc.attributes["type"]
                   when "emission" then :emission
                   when "gap" then :gap
                   #TODO else oops!
                   end

            if (!bc.respond_to?(:structure) or bc.structure.nil?) and
                (!bc.respond_to?(:bloc) or bc.bloc.nil?)
                return Gap.new_gap_broadcast(bc.dtstart, bc.dtend)
            elsif bc.respond_to?(:bloc)
                struct = bc.bloc.segments.map do |segment|
                    Segment.load_from_scheduler(segment)
                end
            else
                struct = bc.structure.segments.map do |segment|
                    Segment.load_from_scheduler(segment)
                end
            end
            name =  type==:emission ? bc.program_id : :gap
            return Broadcast.new(name, type, bc.dtstart, bc.dtend, struct)
        end

        def is_gap?
            return true if @type == :gap
            return false
        end 

        def to_s
            [@name,@dtstart,@dtend].join(", ")
        end
    end

    class PlayoutServer
        attr_reader :broadcasts
        def initialize init, broadcasts = []
            @broadcasts = broadcasts
            @update_scheduled = true
            @global_lock = Monitor.new
            if init.key? :yaml then
                @broadcasts = load_yaml init[:yaml]
                @next_broadcast = get_next
                rotate_broadcast()
            elsif init.key? :scheduler_uri
                @broadcasts = load_from_scheduler 
                @next_broadcast = get_next
                rotate_broadcast()
                @update_scheduled = false
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
                broadcasts << Broadcast.new(broadcast["name"], broadcast["type"], 
                                            broadcast["dtstart"], broadcast["dtend"], struct)
            end
            broadcasts
        end

        def load_from_scheduler
            require 'playout_middleware'
            PlayoutMiddleware::fetch.each do |broadcast|
                #p broadcast
                broadcasts << Broadcast.load_from_scheduler(broadcast)
            end
            broadcasts
        end


        
        # Updates the current and following broadcasts
        # consuming 1 unit from the broadcast list top
        def rotate_broadcast 
            @global_lock.synchronize do 
                @current_broadcast = @next_broadcast
                p "Current broadcast: #{@current_broadcast}" if DEBUG
                @next_broadcast = get_next @current_broadcast
                if @current_broadcast.nil? then
                    return
                end
                @current_broadcast.timer= EventMachine::Timer.new(
                    @current_broadcast.dtend-Time.now) {rotate_broadcast()}
                unless @update_scheduled then
                    EventMachine::defer(update)
                    @update_scheduled = true
                end

            end
        end


        # Returns the following broadcast. It searches in the broadcasts list
        # for the following, discarding any broadcast that lived in the past.
        # 
        # The broadcast list is updated so it must be enclosed by a lock. Isn't
        # done because this method is called inside rotate_broadcast that
        # already adquires the lock
        #
        def get_next bc=nil
            now = bc.nil? ? Time.now : bc.dtend
            next_broadcast = nil
            while next_broadcast.nil?
                if @broadcasts.empty? then
                    # TODO: oops: the bc list is empty? Update is to slow to be done here
                    return nil
                end

                # If the following broadcast only starts in the future, a Gap is inserted
                # or (if the following broadcast is already a Gap, it's merged)
                if @broadcasts[0].dtstart > now then
                    if @broadcasts[0].is_gap? 
                        next_broadcast = Gap.new_gap_broadcast(now, @broadcasts[0].dtend)
                        @broadcasts.shift()
                    else
                        next_broadcast = Gap.new_gap_broadcast(now, @broadcasts[0].dtstart)
                    end
                    p "#{Time.now} -- Next track: gap" if DEBUG
                    break

                # If starded in the past either:
                # - Returns if it hasn't finished or
                # - Is discarded if has already finished
                else
                    if @broadcasts[0].dtend > now
                        next_broadcast = @broadcasts.shift()
                        p "#{Time.now} -- Next track: #{next_broadcast}" if DEBUG
                        break
                    else
                        @broadcasts.shift()
                    end
                end
            end
            next_broadcast
        end

        def update
            @global_lock.synchronize do
                @update_scheduled = false
                p "#{Time.now} -- UPDATE"
            end
        end          
    end
end



