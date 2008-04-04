require File.dirname(__FILE__) + '/../test_helper'

class ProgramScheduleTest < ActiveSupport::TestCase
  
  def setup
    reset_singleton ProgramSchedule
  end
  
  def test_should_create_only_given_emission_types
    assert_no_difference 'RecordedEmission.count' do
      make_update :calendars => { :recorded => '' }
    end
  end
  
  def test_should_create_correct_number_of_emissions
    live_prev = schedule.live_emissions.count
    rec_prev  = schedule.recorded_emissions.count
    pl_prev   = schedule.playlist_emissions.count
    
    make_update
    
    assert_equal live_prev + 91, schedule.live_emissions.count
    assert_equal rec_prev + 13, schedule.recorded_emissions.count
    assert_equal pl_prev + 3, schedule.playlist_emissions.count
  end
  
  def test_should_inactivate_conflicting_emissions
    make_update # clean schedule
    
    assert_difference 'schedule.inactive_emissions.size' do
      e = schedule.recorded_emissions.find_by_date(2008, 4, 9)
      e.description = "hello world!"
      e.save
      # update schedule, there should be a conflict with the modified emission
      make_update 
    end
  end
  
  protected 
  
  def make_update(options = {})
    live     = File.open("#{RAILS_ROOT}/test/calendars/live-test.ics", 'r')
    recorded = File.open("#{RAILS_ROOT}/test/calendars/recorded-test.ics", 'r')
    playlist = File.open("#{RAILS_ROOT}/test/calendars/playlist-test.ics", 'r')
    
    dtstart  = { :year => 2008, :month => 04, :day => 01, :hour => 12, :minute => 00 }
    dtend    = { :year => 2008, :month => 07, :day => 01, :hour => 12, :minute => 00 }
    params   = {:start => dtstart, :end => dtend, 
                :calendars => { :live => live, :recorded => recorded, :playlist => playlist }}
    ignored = schedule.update_emissions(params.merge(options))
    live.close; recorded.close; playlist.close
    ignored
  end
  
  def schedule
    ProgramSchedule.instance
  end
end
