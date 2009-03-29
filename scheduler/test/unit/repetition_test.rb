require File.dirname(__FILE__) + '/../test_helper'

class RepetitionTest < ActiveSupport::TestCase
  
  def test_should_ensure_presence_of_start_time
    assert_no_difference 'Repetition.count' do
      create_repetition :dtstart => nil
    end
  end
  
  def test_should_ensure_presence_of_end_time
    assert_no_difference 'Repetition.count' do
      create_repetition :dtend => nil
    end
  end
  
  def test_should_ensure_presence_of_emission
    assert_no_difference 'Repetition.count' do
      create_repetition :emission => nil
    end
  end
  
  def test_should_create_repetition
    assert_difference 'Repetition.count' do
      create_repetition
    end
  end
  
  protected
  
  def create_repetition(opts = {})
    dtstart = DateTime.new(2008, 5, 5, 9, 0)
    dtend = DateTime.new(2008, 5, 5, 10, 0)
    defaults = { :emission => broadcasts(:live1), :dtstart => dtstart, :dtend => dtend, 
                 :program_schedule => ProgramSchedule.instance }
    record = Repetition.new(defaults.merge(opts))
    record.save
    record
  end
end
