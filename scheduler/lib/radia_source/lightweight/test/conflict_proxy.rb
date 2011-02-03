require 'test/unit'

require 'rubygems'
require 'active_record'

require "#{File.dirname(__FILE__)}/../init" 
NS = RadiaSource::LightWeight


class TestNonPersistentConflict < Test::Unit::TestCase

  t = Time.now
  @@reference_broadcast = NS::Broadcast.new :dtstart => t, :dtend => t + 30.minutes
  @@conflicting_broadcast = NS::Broadcast.new :dtstart => t+15.minutes, :dtend => t + 45.minutes

  
  def test_broadcast_methods
    a = NS::Conflict.new

    assert_respond_to a, :active_broadcast
    assert_respond_to a, :broadcasts

  end


  def test_intersection1
    c = NS::Conflict.new(:active_broadcast => @@reference_broadcast)
    
    assert c.intersects?(@@conflicting_broadcast)
  end

  def test_intersection2
    c = NS::Conflict.new(:broadcasts => [@@reference_broadcast])

    assert c.intersects? @@conflicting_broadcast
  end

  def test_add_new_broadcast
    c = NS::Conflict.new :active_broadcast => @@reference_broadcast

    assert_equal 1, (c.add_new_broadcast @@conflicting_broadcast).count

    #test the filter
    assert_equal 1, (c.add_new_broadcast @@conflicting_broadcast).count
  end

  def test_1_solvable?
    c = NS::Conflict.new(:broadcasts => [@@reference_broadcast])

    assert c.solvable?

    c = NS::Conflict.new(:active_broadcast => @@reference_broadcast)
    c.add_new_broadcast @@reference_broadcast

    assert c.solvable?
    
  end


end
