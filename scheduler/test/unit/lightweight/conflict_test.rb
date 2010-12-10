require File.dirname(__FILE__) + '/../../test_helper'

NS=RadiaSource::LightWeight

class ConflictTest < ActiveSupport::TestCase

  t = Time.now
  @@reference_broadcast = NS::Broadcast.new :dtstart => t, :dtend => t + 30.minutes
  @@conflicting_broadcast = NS::Broadcast.new :dtstart => t+15.minutes, :dtend => t + 45.minutes
  @@yet_another_broadcast = NS::Broadcast.new :dtstart => t+30.minutes, :dtend => t + 55.minutes

  def test_proxy_class
    assert_equal Kernel.const_get(:Conflict), NS::Conflict.proxy_class
  end

  def test_save
    c = NS::Conflict.new(:active_broadcast => @@reference_broadcast)
    
    assert_equal @@reference_broadcast, c.active_broadcast

    c.add_new_broadcast @@conflicting_broadcast
    c.add_new_broadcast @@yet_another_broadcast

    assert c.save

    assert_kind_of Kernel::Conflict, c.po

    pc = Kernel::Conflict.first

    assert_equal pc, c.po
    assert_equal 2, pc.new_broadcasts.count

    
  end
end
