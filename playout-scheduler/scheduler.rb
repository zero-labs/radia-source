module PlayoutScheduler
   
    require 'rubygems'
    require 'eventmachine'
    require 'monitor'

    def self.debug_log(s)
        puts "#{Time.now}(#{Thread.current}) -- #{s}" if DEBUG
    end

    Day = 24*60*60

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
             #dtstart = "#{@dtstart.year}/#{@dtstart.month}/#{@dtstart.day} #{@dtstart.hour}:#{@dtstart.min}:#{@dtstart.sec}"
             #dtend = "#{@dtend.year}/#{@dtend.month}/#{@dtend.day} #{@dtend.hour}:#{@dtend.min}:#{@dtend.sec}"
             "%s: %s | %s" % [@name.ljust(15)[0..14], @dtstart, @dtend]
             #sprintf("%15s: %s | %s\n", @name, @dtstart, @dtend)
        end
    end

    class PlayoutServer
        attr_reader :broadcasts
        FastUpdateItems = 1
        def initialize init, broadcasts = []
            @broadcasts = broadcasts
            @global_lock = Monitor.new
            @update_service = PlayoutScheduler::UpdateService.new(self)
            debug_log("Server PID: #{Process::pid}")

            if init.key? :yaml then
                @broadcasts = load_yaml init[:yaml]
                @next_broadcast = get_next_broadcast
                rotate_broadcast()
            elsif init.key? :scheduler_uri
                # this block is not supost to be a critical section
                # but the lock is done anyway, just to be sure
                # TODO: make this class Singleton and check  Singleton
                # concurrent safetyness
                @global_lock.synchronize { @next_broadcast = get_next_broadcast() }
                rotate_broadcast()

                # Start the update service
                @update_service.start(lambda {|x| update_method(x)})
            end
            dump_brooadcast_queue
        end

        def update(bcasts)
            old_length = @broadcasts.length
            @global_lock.synchronize do
                last_time = @broadcasts.empty? ? Time.now : @broadcasts[-1].dtend
                bcasts = bcasts.select { |x| x.dtstart > last_time }
                @broadcasts +=  bcasts
            end
            #debug_log("%s: old:%2i; added:%2i; new:%2i; time to last: %s" % 
            ##["update ser.".ljust(10)[0...10], old_length, bcasts.length, @broadcasts.length, @broadcasts[-1].dtstart.to_s])
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

        def self.fetch_scheduler(n=0)
            require 'playout_middleware'
            bcasts = PlayoutMiddleware::fetch
            return bcasts if n==0
            nn = (n>bcasts.length)? -1 : n - 1
            return bcasts[0..nn]
        end

        def self.parse_schedule(sched)
            return sched.map { |bc| Broadcast.load_from_scheduler(bc) }
        end

        def self.load_from_scheduler(n=0)
            return parse_schedule(fetch_scheduler(n))
        end


        # Updates the current and following broadcasts
        # consuming 1 unit from the broadcast list top
        #
        # It also checks the list must be updated

        def rotate_broadcast 
            @global_lock.synchronize do 
                now = Time.now
                @current_broadcast = @next_broadcast
                @next_broadcast = get_next_broadcast(@current_broadcast)

                unless @current_broadcast.nil? then
                    @current_broadcast.timer = 
                        EventMachine::Timer.new(@current_broadcast.dtend-now) { rotate_broadcast() }
                end
                
                # Is this update worth???
                #if @broadcasts.length =< FastUpdateItems then
                #    EventMachine::defer{fast_update()}
                #end
                debug_log "%s: %s|%2i queued" % ["Now bc.".ljust(10), @current_broadcast, @broadcasts.length]
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
                    # anyway, on init, I think there is no problem
                    begin
                        fast_update()
                    rescue => why
                        debug_log "BIG UPS! COULD NOT UPDATE:\n  #{why}"
                        next_broadcast = Gap.new_gap_broadcast(now, now+Day)
                    end
                    next
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
                    debug_log "%s gap" % "Next track".ljust(10)
                    break

                # If starded in the past either:
                # - Returns if it hasn't finished or
                # - Is discarded if has already finished
                else
                    if @broadcasts[0].dtend > now
                        next_broadcast = @broadcasts.shift()
                        debug_log "%s: %s"  % ["Next track".ljust(10),next_broadcast]
                        break
                    else
                        @broadcasts.shift()
                    end
                end
            end
            next_broadcast
        end

 

        #

        # Fast update should be a fast but synchronous call
        def fast_update(n=FastUpdateItems+1)
            old_length = @broadcasts.length
            last_time = @broadcasts.empty? ? Time.now : @broadcasts[-1].dtend    

            bcasts = PlayoutServer.load_from_scheduler(n)
            
            #bcasts = bcasts.select { |x| x.dtstart >= last_time }
            @broadcasts +=  bcasts
            debug_log ("%s: old:%2i; added:%2i; new:%2i; last @ %s" % 
            ["fast update".ljust(10)[0...10], old_length, bcasts.length, @broadcasts.length, @broadcasts[-1].dtstart.to_s])
        end


        def dump_brooadcast_queue
            debug_log("Dumping broadcast queue ¬")
            @broadcasts.each { |x| debug_log "%s  %s" % [' '.ljust(10), x] }
            debug_log("`End of bc dump")
        end

        def debug_log s
            PlayoutScheduler::debug_log s
        end
    end

end



