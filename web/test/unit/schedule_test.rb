require File.dirname(__FILE__) + '/../test_helper'

class ScheduleTest < ActiveSupport::TestCase
  fixtures :schedules
  
  def test_new_version
    f = File.open(File.dirname(__FILE__) + '/../calendars/schedule-1.ics', 'r')
    radio = schedules(:radiozero)
    assert_nil radio.current
    assert true, radio.new_version!(f)
    radio.reload
    assert_not_nil radio.current
        
    #assert_equal 5, radio.current.programs.size
    #assert_equal 5, radio.current.program_schedulings.size
    
    f.close
  end
end
