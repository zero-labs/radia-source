
require 'test/unit'

require 'rubygems'
require 'active_record'

require "#{File.dirname(__FILE__)}/../init" 
NS = RadiaSource::LightWeight


class TestNonPersistentBroadcast < Test::Unit::TestCase

  def test_dt_methods
    a = NS::Broadcast.new()

    assert_respond_to a, :dtstart
    assert_respond_to a, :dtend
  end

  def test_intersection
    t = Time.now
    a = NS::Broadcast.new(:dtstart => t, :dtend => t + 1.hour)
    b1 = NS::Broadcast.new(:dtstart => t - 30.minutes, :dtend => t )
    b2 = NS::Broadcast.new(:dtstart => t - 30.minutes, :dtend => t + 45.minutes)
    b3 = NS::Broadcast.new(:dtstart => t + 30.minutes, :dtend => t + 45.minutes)
    b4 = NS::Broadcast.new(:dtstart => t + 30.minutes, :dtend => t + 2.hour)
    b5 = NS::Broadcast.new(:dtstart => t + 1.hour, :dtend => t + 2.hours)

    assert_equal false, a.intersects?(b1)
    assert_equal false, a.intersects?(b5)
    assert a.intersects?(b2)
    assert a.intersects?(b3)
    assert a.intersects?(b4)

  end


  def test_similar?
    t = Time.now
    a = NS::Broadcast.new(:dtstart => t, :dtend => t + 1.hour)
    b = NS::Broadcast.new(:dtstart => t - 30.minutes, :dtend => t )

    assert a.similar? a
    assert_equal false, a.similar?(b)
  end

  def test_activate
    t = Time.now
    a = NS::Broadcast.new(:dtstart => t, :dtend => t + 1.hour)

    assert_nil  a.activate
  end

  def test_dirty?
    t = Time.now
    a = NS::Broadcast.new(:dtstart => t, :dtend => t + 1.hour)

    assert_equal false, a.dirty?
  end

  #test_save must be made in a rails test context!
end
