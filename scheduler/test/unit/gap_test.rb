require File.dirname(__FILE__) + '/../test_helper'

class GapTest < ActiveSupport::TestCase

  def test_should_find_one_gap_in_interval_with_no_broadcasts    
    #a = Gap.find_all(Time.local(2007, 01, 02, 8, 00), Time.local(2007, 01, 03, 8, 00),false)
    #assert_equal 1, a.size
    #assert_equal 24*60*60, a.first.length

    b = Gap.find_all(Time.local(2007, 01, 02, 8, 00), Time.local(2007, 01, 02, 9, 05))
    assert_equal 1, b.size
    assert_equal 65*60, b.first.length
  end
  
  def test_should_find_gaps_between_broadcasts
    assert_equal 3, Gap.find_all(gap_dates[0][:dtstart], gap_dates[5][:dtend]).size
    assert_equal 1, Gap.find_all(gap_dates[0][:dtstart], gap_dates[1][:dtstart]).size
    assert_equal 1, Gap.find_all(gap_dates[0][:dtstart], gap_dates[1][:dtend]).size
    assert_equal 1, Gap.find_all(gap_dates[3][:dtend], gap_dates[4][:dtstart]).size
    assert_equal 1, Gap.find_all(gap_dates[4][:dtend], gap_dates[5][:dtstart]).size
  end
  
  def test_should_find_gaps_before_and_after_events_partially_outside_the_interval
    assert_equal 1, Gap.find_all(gap_dates[0][:dtstart] + 60.minutes, gap_dates[1][:dtstart]).size
    assert_equal 2, Gap.find_all(gap_dates[3][:dtend] - 60*5, gap_dates[5][:dtstart] + 5*60).size
  end
  
  protected
  
  def gap_dates
    [{ :dtstart => Time.local(2007, 01, 03,  8, 00), :dtend => Time.local(2007, 01, 03, 10, 00) },
     { :dtstart => Time.local(2007, 01, 03, 10, 05), :dtend => Time.local(2007, 01, 03, 10, 30) },
     { :dtstart => Time.local(2007, 01, 03, 10, 30), :dtend => Time.local(2007, 01, 03, 11, 00) },
     { :dtstart => Time.local(2007, 01, 03, 11, 00), :dtend => Time.local(2007, 01, 03, 11, 30) },
     { :dtstart => Time.local(2007, 01, 03, 12, 00), :dtend => Time.local(2007, 01, 03, 13, 00) },    
     { :dtstart => Time.local(2007, 01, 03, 13, 05), :dtend => Time.local(2007, 01, 03, 14, 00) }]
  end
  
end
