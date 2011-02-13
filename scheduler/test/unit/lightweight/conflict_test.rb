require File.dirname(__FILE__) + '/../../test_helper'

NS=RadiaSource::LightWeight

class ConflictTest < ActiveSupport::TestCase

  tmp = Time.now
  t = Time.utc(tmp.year, tmp.month, tmp.day+1, 0, 0)
  @@reference_broadcast = NS::Broadcast.new :dtstart => t, :dtend => t + 30.minutes
  @@conflicting_broadcast = NS::Broadcast.new :dtstart => t+15.minutes, :dtend => t + 45.minutes
  @@yet_another_broadcast = NS::Broadcast.new :dtstart => t+30.minutes, :dtend => t + 55.minutes

  def test_proxy_class
    assert_equal Kernel.const_get(:Conflict), NS::Conflict.proxy_class
  end

  def test_save
    c = NS::Conflict.new
    

    c.add_broadcast @@conflicting_broadcast
    c.add_broadcast @@yet_another_broadcast

    assert c.save!

    assert_kind_of Kernel::Conflict, c.po

    # WATCH OUT: I CHOOSE LAST because during save two conflicts are created
    # since the automatic conflict creation in the broadcast class is enabled
    pc = Kernel::Conflict.all.last

    #Kernel::Conflict.all.each do |x| 
    #  p "#{x.id} :: #{x.active_broadcast.pp unless x.active_broadcast.nil?}"
    #  x.broadcasts.each do |y|
    #    p " - #{y.pp}"
    #  end
    #end


    assert_equal pc, c.po
    assert_equal 2, pc.broadcasts.count

    
  end
end
