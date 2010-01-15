#!/usr/bin/ruby


require 'rubygems'
require 'eventmachine'

now = Time.now
min = 60
yaml= <<eoyml
  - name: "buraco"
    dtstart: #{(now+30).strftime("%Y-%m-%d %H:%M:%S")} +00:00
    dtend:   #{(now+1*min).strftime("%Y-%m-%d %H:%M:%S")} +00:00 
    structure:
    -
      type: "Single"
      uri: "/singles/buraco_testfile.mp3"
      length: ~
  - name: "3min"
    dtstart: #{(now+1*min).strftime("%Y-%m-%d %H:%M:%S")} +00:00
    dtend:   #{(now+2*min).strftime("%Y-%m-%d %H:%M:%S")} +00:00 
    structure:
    - 
      type: "Playlist"
      uri: "/playlists/3min.m3u"
      length: ~
eoyml
f = File.open("/tmp/schedule_1.yml","w")
f.write yaml
f.close

dir = File.dirname(File.expand_path(__FILE__))

require File.join(dir, '../config')
require File.join(dir, '../playout-server')

EventMachine::run { run({:yaml => File.open("/tmp/schedule_1.yml")}) }
