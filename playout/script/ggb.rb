#!/usr/bin/ruby
#
#



APP_DIR = File.join(File.dirname(File.expand_path(__FILE__)), '..')
Dir.chdir(APP_DIR)

require File.join('config', 'environment')


scheduler = ScheduleUpdater.check_and_download

now = Time.now


bcasts = scheduler.broadcasts
bcasts = bcasts.find_all { |x| x if now < x.dtstart }

next_bcast = bcasts.delete_at(0)
next_bcast.check_and_download




