require File.dirname(__FILE__) + '/../test_helper'

class ScheduleTest < ActiveSupport::TestCase
  
  def test_parse
    f = File.open(File.dirname(__FILE__) + '/../calendars/schedule-1.ics', 'r')
    cals = Icalendar.parse(f)
    
    s = Schedule.create
    s.new_version(f)
    
    assert_equal 1, s.schedule_versions.size
    
    assert_equal cals.events.size, s.current.program_schedulings.size
    
    f.close
  end
end
