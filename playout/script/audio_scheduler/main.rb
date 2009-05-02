#!/usr/bin/ruby
#
#

require 'rubygems'
require 'rufus/scheduler'


$DBG = 1 #Flag for debugging that doesn't mess up with ruby $DEBUG embedded var

APP_DIR = File.join(File.dirname(File.expand_path(__FILE__)), '../..')
Dir.chdir(APP_DIR)

require File.join('config', 'environment')


$log_file = File.open "log/audio_scheduler.log", "a"
$log_file.syswrite("  -- STARTING TO LOG (#{Time.now.getlocal})--\n")


# An instance of this class should manage the liquisoap sources. 
# For now there are 2 kinds of sources:
#   - equeues for files and playlists
#   - http for live shows
# Because of threads in  rufus, race conditions may happen in future
# development

class Controller
    attr_accessor :equeues_sources, :http_sources
    SourcesPerType = 4 # 2 is the minimun ("double buffer" approach
    def initialize
        @equeues_sources_id = -1
        @http_sources_id = -1
    end

    
    def next_source asset # attributes a source
        case asset.kind
        when :single
            @equeues_sources_id = (@equeues_sources_id + 1) %  SourcesPerType
        end
    end

    def go_to_air asset # Change when ready to talk with liquidsoap (I don't have files for now)
        case asset.kind
        when :single
            $log_file.syswrite("on air@#{Time.now.getlocal}: single->#{asset.id}, length-> #{asset.length}. Source: #{asset.on_air_resource}\n")
        end
        puts Time.now.to_s+ " => " + self.dtstart.to_s
        puts "source: #{asset.on_air_resource}"
    end
end



# Abstract media source to be delivered to liquidsoap
class MediaSource
    attr_reader :dtstart, :kind
    attr_accessor :on_air_resource, :length
    def initialize kind, dtstart
        @kind = kind   # file, playlist, live
        @dtstart = dtstart 
        @expected_length = 0.0  #this is the expected length (vs a true, computed length)
    end

    def length
        @length.nil? ? @expected_length : @length
    end
end

# single file. TODO: add filename (and many other things ;)
class Single < MediaSource
    def initialize segment, dtstart
        super(:single, dtstart)
        @id = segment.single.id
        @expected_length = segment.length
    end

end

# playlist TODO:
#  - get and parse the playlist file
#  - get info about single files that are listed in the playlist
#  - construct the playlist
#
class Playlist < MediaSource
    def initialize segment, dtstart, random = false
        super(:playlist, dtstart)
        @expected_length = segment.length
        @ids = [] 
        @random = random
    end

    private
    def compute
        tmp_length = 0.0
        while tmp_length < @expected_length
            @ids.push(next_source)
        end
    end

    def next_source
        #if random
        #else give next in order
    end
end


class HttpSource < MediaSource
    def initialize segment, dtstart
        super(:http, dtstart)
        # @url = segment.url 
    end
end


#just a container for information. Used with PlayoutScheduler's
# @schedule_list
class ScheduleUnit
    attr_accessor :id, :asset
    def initialize id, asset
        @id = id
        @asset = asset
    end
end

class PlayoutScheduler
    attr_accessor :scheduler 
    PreFetchThreshold = 3
    def initialize
        @scheduler = Rufus::Scheduler.start_new
        @schedule_list = []
        @controller = Controller.new
    end

    def broadcasts
        tmp = ScheduleUpdater.check_and_download 
        if @schedule_list.length == 0
            tmp.broadcasts.find_all {|x| x.dtstart > Time.now }
        else
            # if scheduled list is not nil, we want only are interested in
            #the ones after the last one 
            time = @scheduler.get_job(@schedule_list[-1].id).schedule_info
            tmp.broadcasts.find_all {|x| x.dtstart > time }
        end
    end

    # middleware: Rails Active Record::Base derived classes ->mine 'a lot simpler'
    # classes that will live in the memory for some time
    def self.segment_to_media_asset segment, dtstart
        if segment.respond_to? 'single'
        #if segment.asset_type == :single
            Single.new segment, dtstart
        else
            # log the not implement issue
            puts "segment 2 media not implemented for this segment type"
        end
    end
    
    def do_schedule 
        broadcasts.each_with_index do |bc, i|
            if not bc.respond_to?('bloc'):
                # is some kind of gap.
                gap_do_something bc, :nobloc
                if not $DBG.nil?: puts "gap" end
                next
            end

            tmp_time = bc.dtstart
            bc.bloc.segments.each_with_index  do |e, j|
                if not e.respond_to?('length') or e.length.nil?
                    # expected length is mandatory. If I don't know it, I'll ignore it
                    # TODO: log this
                    puts "Some item with no length"
                    next
                end
                media = PlayoutScheduler.segment_to_media_asset e, tmp_time
                #TODO: test  media.nil?
                media.on_air_resource = @controller.next_source media

                test_time = tmp_time # debbuging purposes. In the future eliminate the test_time var
                if not $DBG.nil?: puts "scheduling at #{test_time}" end

                id = scheduler.at test_time do |job_id, at, params|
                    @controller.go_to_air media
                    delete_job job_id
                    if @schedule_list.length == PreFetchThreshold # recursivity here! this enforces the non stop scheduling 
                        do_schedule
                    end
                end
                
                tmp_time += media.length
                @schedule_list.push( ScheduleUnit.new(id, media ))
            end

            # what if the sum of all segments is less than the broadcast
            # length?? Let's do something
            if tmp_time < bc.dtend
                gap_do_something bc, :to_short
            end
        end
    end

    private


    # logging may be hooked here
    def delete_job job_id
        @schedule_list.delete_if {|x| x.id == job_id }
    end

    # What will we do when there is a gap?
    def gap_do_something bc, type=:known
        case type
        when :nobloc

        end
    end
end

#if __FILE__ == $0
    main_scheduler = PlayoutScheduler.new
    main_scheduler.do_schedule
    main_scheduler.scheduler.join
#end




#EOF

