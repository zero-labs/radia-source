require File.dirname(__FILE__) + '/../test_helper'

class ProgramScheduleTest < ActiveSupport::TestCase
  
  def setup
    reset_singleton ProgramSchedule
  end
  
  def test_should_create_only_given_emission_types
    assert_no_difference 'schedule.recorded_emissions.size' do
      make_update :recorded => ''
    end
  end
  
  def test_should_create_correct_number_of_emissions
    live_prev = schedule.live_emissions.count
    rec_prev  = schedule.recorded_emissions.count
    pl_prev   = schedule.playlist_emissions.count
    rep_prev  = schedule.repeated_emissions.count
    
    make_update
    
    assert_equal live_prev + 91, schedule.live_emissions.count
    assert_equal rec_prev  + 13, schedule.recorded_emissions.count
    assert_equal pl_prev   + 3, schedule.playlist_emissions.count
    assert_equal rep_prev  + 26, schedule.repeated_emissions.count
  end
  
  def test_should_associate_repetitions_with_emissions
    make_update :live => '', :playlist => ''    
    e = schedule.recorded_emissions.find_by_date(2008, 4, 9)
    assert_equal 2, e.repeated_emissions.size
  end
  
  def test_should_inactivate_conflicting_emissions
    make_update # clean schedule
    
    assert_difference 'schedule.inactive_emissions.size' do
      e = schedule.recorded_emissions.find_by_date(2008, 4, 9)
      e.description = "hello world!"
      e.save
      # update schedule, there should be a conflict with the modified emission
      File.open("#{RAILS_ROOT}/test/calendars/recorded-test-2.ics") do |f|
        make_update :recorded => f 
      end
    end
  end
  
  def test_should_move_repetitions_of_inactive_emissions
    flunk
    
    make_update :live => '', :playlist => ''
    
    e = schedule.recorded_emissions.find_by_date(2008, 4, 9)
    assert_equal 2, e.repeated_emissions.size
    
    File.open("#{RAILS_ROOT}/test/calendars/recorded-test-2.ics") do |f|
      make_update :recorded => f, :repeated => '', :live => '', :playlist => ''
    end
    
    new_e = schedule.recorded_emissions.find_by_date(2008, 4, 9)
    
    assert [], e.repeated_emissions
    assert_equal 2, new_e.repeated_emissions.size
  end
  
  protected 
  
  def make_update(calendars = {})
    live     = File.open("#{RAILS_ROOT}/test/calendars/live-test.ics", 'r')
    recorded = File.open("#{RAILS_ROOT}/test/calendars/recorded-test.ics", 'r')
    playlist = File.open("#{RAILS_ROOT}/test/calendars/playlist-test.ics", 'r')
    repeated = File.open("#{RAILS_ROOT}/test/calendars/repeated-test.ics")
    
    dtstart  = { :year => 2008, :month => 04, :day => 01, :hour => 12, :minute => 00 }
    dtend    = { :year => 2008, :month => 07, :day => 01, :hour => 12, :minute => 00 }
    
    defaults = { :live => live, :recorded => recorded, :playlist => playlist, :repeated => repeated }
    
    params   = { :start => dtstart, :end => dtend, :calendars => defaults.merge(calendars)}
    ignored = schedule.update_emissions(params)
    live.close; recorded.close; playlist.close
    ignored
  end
  
  def schedule
    ProgramSchedule.instance
  end
end
