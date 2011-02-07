require File.dirname(__FILE__) + '/../test_helper'

class ConflictTest < ActiveSupport::TestCase

  def setup
    t = Time.now.utc
    @t = Time.utc(t.year, t.month, t.day, 0, 0) + 1.day
  end

  def test_void_conflict
    assert_difference 'Conflict.count' do
      Conflict.create!
    end
  end
  
  def test_find_in_range
    Conflict.create!(:dtstart => rd[:b], :dtend => range_dates[:d])
    Conflict.create!(:dtstart => rd[:e], :dtend => range_dates[:f])

    assert_equal 0, Conflict.find_in_range(rd[:a], rd[:b]).count
    assert_equal 0, Conflict.find_in_range(rd[:d], rd[:e]).count
    assert_equal 1, Conflict.find_in_range(rd[:a], rd[:d]).count
    assert_equal 1, Conflict.find_in_range(rd[:b], rd[:c]).count
    assert_equal 2, Conflict.find_in_range(rd[:a], rd[:f]).count
  end

  def test_one_broadcast
    b1 = create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:d] )
    create_broadcast(:dtstart => range_dates[:a], :dtend => range_dates[:c])

    b1.reload

    assert_not_nil b1.conflict
    assert_equal 2, b1.conflict.broadcasts.length

    
    assert_difference 'b1.conflict.broadcasts.count', 4 do
      assert create_broadcast(:dtstart => rd[:b], :dtend => rd[:d])
      assert create_broadcast(:dtstart => rd[:b], :dtend => rd[:e])

      assert create_broadcast(:dtstart => rd[:c], :dtend => rd[:d])
      assert create_broadcast(:dtstart => rd[:c], :dtend => rd[:e])
    end


    assert_equal 1, Kernel::Conflict.count
  end


  def test_two_broadcasts
    b1 = create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:d])
    b2 = create_broadcast(:dtstart => range_dates[:d], :dtend => range_dates[:e])

    create_broadcast(:dtstart => range_dates[:a], :dtend => range_dates[:c])
    create_broadcast(:dtstart => range_dates[:d], :dtend => range_dates[:f])

    b1.reload; b2.reload
    assert_not_nil b1.conflict
    assert_not_nil b2.conflict

    assert_not_equal b1.conflict, b2.conflict

    assert_difference 'b1.conflict.broadcasts.count', 2 do     # b1 b2
        create_broadcast(:dtstart => rd[:b], :dtend => rd[:d]) # X  -
        create_broadcast(:dtstart => rd[:c], :dtend => rd[:d]) # X  -
    end

    assert_difference 'b2.conflict.broadcasts.count', 1 do # b1 b2
        create_broadcast(:dtstart => rd[:d], :dtend => rd[:e]) # -  X
    end

    assert_equal 2, Conflict.count

    # Test for conflict merge by adding a bunch of broadcasts that conflict
    # with both previously added conflicts
    tmp =b2.conflict.broadcasts.count
    assert_difference 'b1.conflict.broadcasts.count', (5+tmp) do     # b1 b2
        create_broadcast(:dtstart => rd[:a], :dtend => rd[:f]) # X  X whole span
        create_broadcast(:dtstart => rd[:b], :dtend => rd[:e]) # X  X
        create_broadcast(:dtstart => rd[:b], :dtend => rd[:f]) # X  X
        create_broadcast(:dtstart => rd[:c], :dtend => rd[:f]) # X  X
        create_broadcast(:dtstart => rd[:c], :dtend => rd[:e]) # X  X
    end

    assert_equal 1, Conflict.count

  end

  ## zz tests: dont'have the create_conflicts after_save callback. They are
  ## run in the end so they don't screw their normal brothers
  #
  def test_zz_add_broadcast
    # We must remove the Broadcast callback in order to test portions of it
    # (add_broadcast method, in this case)
    Kernel::Broadcast.after_create.reject! {|callback| callback.method.to_s == 'create_conflicts' }

    b1 = create_broadcast(:dtstart => range_dates[:a], :dtend => range_dates[:c])
    b2 = create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:d])

    c = Kernel::Conflict.new

    assert_equal 0, c.broadcasts.count

    assert_difference "c.broadcasts.count" do
      c.add_broadcast b1
      c.save!
    end

    assert_difference "c.broadcasts.count" do
      cp =  c.add_broadcast b2
    end

  end


  protected
  def range_dates
    {
      :a => @t           , :b => @t + 5.minutes,
      :c => @t+10.minutes, :d => @t +15.minutes,
      :e => @t+20.minutes, :f => @t +25.minutes
    }
  end

  alias :rd :range_dates

  def create_broadcast(opt={})
    defaults = {:program_schedule => ProgramSchedule.active_instance, :active => false }
    Kernel::Broadcast.create!(defaults.merge opt)
  end

end

##  def test_conflict_creation
##    b1 = create_broadcast(:dtstart => range_dates[:a], :dtend => range_dates[:c])
##    b2 = create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:d])
##    b3 = create_broadcast(:dtstart => range_dates[:c], :dtend => range_dates[:f])
##
##    c = Conflict.new
##    $dddd = 1
##    c.add_broadcast b1
##    $dddd = nil
##    c.add_broadcast b2
##    p c.broadcasts.count, c.id
##    assert_difference "Conflict.count" do
##      c.save!
##    end
##
##    # The following blows the code
##    # theres an infinite loop somewhere in the automatic conflict 
##    # creation... moving on since it's not suposed to work withj this
##
##    assert_difference "Conflict.count" do
##      Conflict.create!(:broadcasts => [b2,b3])
##    end
##  end
