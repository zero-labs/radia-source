require File.dirname(__FILE__) + '/../test_helper'

class ConflictTest < ActiveSupport::TestCase

  def setup
    t = Time.now.utc
    @t = Time.utc(t.year, t.month, t.day, 0, 0) + 1.day
  end

  def test_void_conflict
    assert_raise ActiveRecord::RecordInvalid do
      Conflict.create!
    end
  end


  def test_conflict_creation
    b1 = create_broadcast(:dtstart => range_dates[:a], :dtend => range_dates[:c])
    b2 = create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:d])
    b3 = create_broadcast(:dtstart => range_dates[:c], :dtend => range_dates[:f])

    c = Conflict.new
    c.add_broadcast b1
    c.add_broadcast b2
    assert_difference "Conflict.count" do
      c.save!
    end

    assert_difference "Conflict.count" do
      Conflict.create!(:broadcasts => [b2,b3])
    end
  end


  def test_one_active_broadcast
    b1 = create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:d], :active => true )
    create_broadcast(:dtstart => range_dates[:a], :dtend => range_dates[:c])

    assert_not_nil b1.main_conflict
    assert_equal 1, b1.main_conflict.broadcasts.count

    assert_difference 'b1.main_conflict.broadcasts.count', 4 do
      create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:d])
    $dddd =1
      create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:e])
    $dddd = nil
      create_broadcast(:dtstart => range_dates[:c], :dtend => range_dates[:d])
      create_broadcast(:dtstart => range_dates[:c], :dtend => range_dates[:e])
      b1.reload
    end

    assert_equal 1, Kernel::Conflict.count
  end

  def test_two_active_broadcasts
    b1 = create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:d], :active => true )
    b2 = create_broadcast(:dtstart => range_dates[:d], :dtend => range_dates[:e], :active => true )

    create_broadcast(:dtstart => range_dates[:a], :dtend => range_dates[:c])
    create_broadcast(:dtstart => range_dates[:d], :dtend => range_dates[:f])

    assert_not_nil b1.main_conflict
    assert_not_nil b2.main_conflict

    assert_not_equal b1.main_conflict, b2.main_conflict

    assert_difference 'b1.main_conflict.broadcasts.count', 7 do
      assert_difference 'b2.main_conflict.broadcasts.count', 6 do                # b1 b2
        create_broadcast(:dtstart => range_dates[:a], :dtend => range_dates[:f]) # X  X whole span
        create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:d]) # X  -
        create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:e]) # X  X
        create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:f]) # X  X
        create_broadcast(:dtstart => range_dates[:c], :dtend => range_dates[:d]) # X  -
        create_broadcast(:dtstart => range_dates[:c], :dtend => range_dates[:f]) # X  X
        create_broadcast(:dtstart => range_dates[:c], :dtend => range_dates[:e]) # X  X
        create_broadcast(:dtstart => range_dates[:d], :dtend => range_dates[:e]) # -  X
        
        b2.reload
      end
      b1.reload
    end

    assert_equal 2, Conflict.count
    assert (b1.dtstart == b1.main_conflict.dtstart and b1.dtend == b1.main_conflict.dtend)
    assert (b2.dtstart == b2.main_conflict.dtstart and b2.dtend == b2.main_conflict.dtend)

  end

  #def test_inactive_broadcasts_only
  #  b1 = create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:d] )

  #  create_broadcast(:dtstart => range_dates[:a], :dtend => range_dates[:c])
  #  create_broadcast(:dtstart => range_dates[:d], :dtend => range_dates[:f])
  #end

  ## zz tests: dont'have the create_conflicts after_save callback. They are
  ## run in the end so they don't screw their normal brothers
  #
  def test_zz_add_broadcast
    # We must remove the Broadcast callback in order to test portions of it
    # (add_broadcast method, in this case)
    Kernel::Broadcast.after_save.reject! {|callback| callback.method.to_s == 'create_conflicts' }

    b1 = create_broadcast(:dtstart => range_dates[:a], :dtend => range_dates[:c], :active => true)
    b2 = create_broadcast(:dtstart => range_dates[:b], :dtend => range_dates[:d])

    c = Conflict.new

    # add an active broadcast
    assert_no_difference "c.broadcasts.count" do
      c.add_broadcast b1
      c.save!
    end
    assert_not_nil c.active_broadcast

    # add an inactive broadcast
    assert_difference "c.broadcasts.count" do
      cp =  c.add_broadcast b2
      c.save!
    end
  end

  ## No longer used...

  def test_find_intersection

    ## non intersecpting broadcasts
    assert_nil Kernel::Conflict.send(:find_intersection, rd[:a], rd[:b], rd[:b], rd[:c])
    assert_nil Kernel::Conflict.send(:find_intersection, rd[:a], rd[:b], rd[:c], rd[:d])
    assert_nil Kernel::Conflict.send(:find_intersection, rd[:b], rd[:c], rd[:a], rd[:b])
    assert_nil Kernel::Conflict.send(:find_intersection, rd[:c], rd[:d], rd[:a], rd[:b])

    ## big broadcast contains smaller one
    assert_equal [rd[:d], rd[:e]], 
      Kernel::Conflict.send(:find_intersection, rd[:a], rd[:f], rd[:d], rd[:e])
    assert_equal [rd[:d], rd[:e]], 
      Kernel::Conflict.send(:find_intersection, rd[:d], rd[:e], rd[:a], rd[:f])

    ## broadcast starts before start of the other but ends in the middle of other
    assert_equal [rd[:b], rd[:c]],
     Kernel::Conflict.send(:find_intersection, rd[:b], rd[:e], rd[:a], rd[:c])
    assert_equal [rd[:b], rd[:c]],
     Kernel::Conflict.send(:find_intersection, rd[:a], rd[:c], rd[:b], rd[:e])
    
    ## broadcast starts before the middle the other but ends afterwards
    assert_equal [rd[:c], rd[:e]],
      Kernel::Conflict.send(:find_intersection, rd[:b], rd[:e], rd[:c], rd[:f])
    assert_equal [rd[:c], rd[:e]],
      Kernel::Conflict.send(:find_intersection, rd[:c], rd[:f], rd[:b], rd[:e])
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
    Broadcast.create!(defaults.merge opt)
  end

end
