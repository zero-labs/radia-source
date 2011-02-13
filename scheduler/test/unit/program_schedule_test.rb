require File.dirname(__FILE__) + '/../test_helper'
require 'array'


class ProgramScheduleTest < ActiveSupport::TestCase
  
###  def setup
###    reset_singleton ProgramSchedule
###  end
###  
###  def test_should_create_correct_number_of_originals
###    live_prev = schedule.originals_by_type('Live').size
###    rec_prev  = schedule.originals_by_type('Recorded').size
###    pl_prev   = schedule.originals_by_type('Playlist').size
###    rep_prev  = schedule.repetitions.count
###    
###    make_update :live
###    assert_equal live_prev + 91, schedule.originals_by_type('Live').size
###    
###    make_update :recorded
###    assert_equal rec_prev  + 13, schedule.originals_by_type('Recorded').size
###    
###    make_update :playlist
###    assert_equal pl_prev   + 3, schedule.originals_by_type('Playlist').size
###    
###    make_update :repetitions
###    assert_equal rep_prev  + 26, schedule.repetitions.count
###  end
###  
###  def test_should_associate_repetitions_with_originals
###    make_update :recorded
###    make_update :repetitions
###    e = schedule.originals.find_by_date(2008, 4, 9)
###    assert_equal 2, e.repetitions.size
###  end
  
  protected 
  
  def make_update(type)
    to_use = "#{RAILS_ROOT}/test/calendars/live-test.ics"     if type == :live
    to_use = "#{RAILS_ROOT}/test/calendars/recorded-test.ics" if type == :recorded
    to_use = "#{RAILS_ROOT}/test/calendars/playlist-test.ics" if type == :playlist
    to_use = "#{RAILS_ROOT}/test/calendars/repeated-test.ics" if type == :repetitions

    type_id = (type == :repetitions ? 0 : structure_templates(type).id)  
    dtstart = { :year => 2008, :month => 04, :day => 01, :hour => 12, :minute => 00 }
    dtend   = { :year => 2008, :month => 07, :day => 01, :hour => 12, :minute => 00 }
    calendar = File.open(to_use, 'r')
    
    params = { :start => dtstart, :end => dtend, :calendar => calendar, 
               :type => type_id, :program_schedule => schedule }
    result = schedule.load_calendar(params)
    # See /lib/array.rb to know about the to_h method
    schedule.update_originals(result[:to_create].to_h {|v| v }, result[:to_destroy].to_h { |v| v}) 
    calendar.close
  end
  
  def schedule
    ProgramSchedule.active_instance
  end
  
end
