require File.dirname(__FILE__) + '/../test_helper'

class BroadcastTest < ActiveSupport::TestCase

  def test_should_require_start_and_end_date
    assert_no_difference 'Broadcast.count' do
      create_broadcast(:dtstart => nil, :dtend => nil)
      create_broadcast(:dtstart => nil)
      create_broadcast(:dtend => nil)
    end
  end

  def test_should_ensure_start_before_end
    assert_no_difference 'Broadcast.count' do
      create_broadcast(:dtstart => DateTime.new(2008, 01, 01, 14, 00), 
      :dtend => DateTime.new(2008, 01, 01, 13, 00))
    end
  end
  
  def test_date_shorthand_parameters
    e = broadcasts(:live1)
    assert_equal e.dtstart.year, e.year
    assert_equal e.dtstart.month, e.month
    assert_equal e.dtstart.day, e.day
  end

  def test_date_finders
    assert_equal 2, Broadcast.find_all_by_date(2008, 1).size
    assert_equal 2, Broadcast.find_all_by_date(2008, 2).size
    assert_equal 1, Broadcast.find_all_by_date(2008, 1, 14).size
    assert_equal true, Broadcast.has_broadcasts?(DateTime.new(2008, 01, 14))
  end

  def test_should_ensure_broadcasts_dont_overlap
    create_broadcast
    
    # partially inside
    assert_no_difference 'Broadcast.count' do
      create_broadcast(:dtstart => DateTime.new(2008, 01, 01, 11, 30), 
                       :dtend => DateTime.new(2008, 01, 01, 12, 05))
    end

    # at exactly the same times
    assert_no_difference 'Broadcast.count' do
      create_broadcast 
    end
    
    # inside interval
    assert_no_difference 'Broadcast.count' do
      create_broadcast(:dtstart => DateTime.new(2008, 01, 01, 12, 10), 
                       :dtend => DateTime.new(2008, 01, 01, 12, 30))
    end
    
    # partially outside
    assert_no_difference 'Broadcast.count' do
      create_broadcast(:dtstart => DateTime.new(2008, 01, 01, 12, 30), 
                       :dtend => DateTime.new(2008, 01, 01, 13, 05))
    end
  end
  
  def test_should_create_broadcasts
    # broadcast before
    create_broadcast
    # another broadcast, after the one that'll be created
    create_broadcast(:dtstart => DateTime.new(2008, 01, 01, 14, 00), 
                     :dtend => DateTime.new(2008, 01, 01, 15, 00))
    assert_difference 'Broadcast.count' do
      # new broadcast, exactly inside open interval
      create_broadcast(:dtstart => DateTime.new(2008, 01, 01, 13, 00), 
      :dtend => DateTime.new(2008, 01, 01, 14, 00))
    end
  end
  
  def test_should_find_correct_number_in_range    
    # There shouldn't be any broadcasts
    assert_equal 0, Broadcast.find_in_range(range_dates[:a], range_dates[:f]).size
    create_broadcast(:dtstart => (range_dates[:a] - 360), :dtend => (range_dates[:a] + 60)) 
    assert_equal 1, Broadcast.find_in_range(range_dates[:a], range_dates[:f]).size
    
    create_broadcast(:dtstart => range_dates[:b] + 60, :dtend => range_dates[:c] - 60)    
    assert_equal 2, Broadcast.find_in_range(range_dates[:a], range_dates[:f]).size 
    
    create_broadcast(:dtstart => range_dates[:c], :dtend => range_dates[:d])               
    assert_equal 3, Broadcast.find_in_range(range_dates[:a], range_dates[:f]).size
    
    create_broadcast(:dtstart => range_dates[:d], :dtend => range_dates[:e] - 60)
    assert_equal 4, Broadcast.find_in_range(range_dates[:a], range_dates[:f]).size
  end
  
  def test_range_should_find_broadcasts_partially_outside_the_interval    
    # There shouldn't be broadcasts in this interval
    assert_equal 0, Broadcast.find_in_range(range_dates[:b], range_dates[:c]).size
    
    # Broadcast ends after A, should appear in [a, b]
    create_broadcast(:dtstart => (range_dates[:a] - 360), :dtend => (range_dates[:a] + 60)) 
    assert_equal 1, Broadcast.find_in_range(range_dates[:a], range_dates[:b]).size
    
    # Broadcast begins before D, ends after e, should appear in [d, e]
    create_broadcast(:dtstart => range_dates[:d] - 60, :dtend => range_dates[:e] + 60)
    assert_equal 1, Broadcast.find_in_range(range_dates[:d], range_dates[:e]).size
  end
  
  def test_range_should_find_broadcast_within_interval
    # Broadcast between B and C (with blank space around it)
    create_broadcast(:dtstart => range_dates[:b] + 60, :dtend => range_dates[:c] - 60)      
    assert_equal 1, Broadcast.find_in_range(range_dates[:b], range_dates[:c]).size
    
    # Broadcast is between C and D (exactly)
    create_broadcast(:dtstart => range_dates[:c], :dtend => range_dates[:d])               
    assert_equal 1, Broadcast.find_in_range(range_dates[:c], range_dates[:d]).size
    assert_equal 1, Broadcast.find_in_range(range_dates[:c] - 10, range_dates[:d]).size
    assert_equal 1, Broadcast.find_in_range(range_dates[:c], range_dates[:d] + 10).size
    assert_equal 2, Broadcast.find_in_range(range_dates[:b], range_dates[:d]).size
  end

  protected
  
  def range_dates
    { :a => Time.local(2008, 2, 1, 12, 00), :b => Time.local(2008, 2, 1, 12, 10),
      :c => Time.local(2008, 2, 1, 12, 40), :d => Time.local(2008, 2, 1, 12, 50),
      :e => Time.local(2008, 2, 1, 13, 00), :f => Time.local(2008, 2, 1, 14, 00) }
  end

  def create_broadcast(options = {})
    defaults = {:dtstart => DateTime.new(2008, 01, 01, 12, 00), 
                :dtend => DateTime.new(2008, 01, 01, 13, 00),
                :program_schedule => ProgramSchedule.instance}
    record = Broadcast.new(defaults.merge(options))
    record.save
    record
  end
end
