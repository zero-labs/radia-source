module PlayoutScheduler
   
    require 'rubygems'
    require 'eventmachine'
    require 'monitor'

    def self.debug_log(s)
        puts "#{Time.now} -- #{s}" if DEBUG
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
                @next_broadcast = get_next_broadcast
                rotate_broadcast()
            elsif init.key? :scheduler_uri
                @broadcasts = load_from_scheduler 
                @next_broadcast = get_next_broadcast
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
        #
        # It also checks the list must be updated
        # TODO: move this check to a different thread (an update service thread)
        def rotate_broadcast 
            @global_lock.synchronize do 
                now = Time.now
                @current_broadcast = @next_broadcast
                debug_log "Current broadcast: #{@current_broadcast}"
                @next_broadcast = get_next_broadcast @current_broadcast
                if @current_broadcast.nil? then
                    return
                end
                @current_broadcast.timer = EventMachine::Timer.new(
                    @current_broadcast.dtend- now ) {rotate_broadcast()}
                
                # TODO: move the following conditions to an update service 
                if @broadcasts.length < 10 or @broadcasts[-1].dtstart-now < 3600 then
                    @update_scheduled = 1
                end
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
        def get_next_broadcast bc=nil
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
                    debug_log "Next track: gap"
                    break

                # If starded in the past either:
                # - Returns if it hasn't finished or
                # - Is discarded if has already finished
                else
                    if @broadcasts[0].dtend > now
                        next_broadcast = @broadcasts.shift()
                        debug_log "Next track: #{next_broadcast}" 
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
                @broadcasts += load_from_scheduler
                debug_log "update" 
            end
        end          

        def debug_log s
            PlayoutScheduler::debug_log s
        end
    end

end



