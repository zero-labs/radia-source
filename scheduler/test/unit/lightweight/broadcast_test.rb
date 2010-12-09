require File.dirname(__FILE__) + '/../../test_helper'

NS=RadiaSource::LightWeight

class BroadcastTest < ActiveSupport::TestCase

  def test_proxy_class
    assert_equal Kernel.const_get(:Broadcast), NS::Broadcast.proxy_class
  end

  def test_save
    t = Time.now
    b = NS::Broadcast.new :dtstart => t, :dtend => t + 30.minutes

    assert_difference 'Broadcast.count' do
      b.save!
    end
  end

  def test_save_with_errors
    t = Time.now
    b = NS::Broadcast.new :dtstart => t, :dtend => t - 30.minutes

    assert_no_difference 'Broadcast.count' do
      b.save
    end
  end

  def test_destroy
    t = Time.now
    b = NS::Broadcast.new :dtstart => t, :dtend => t + 30.minutes

    assert b.save

    assert_difference 'Broadcast.count', -1 do
      b.destroy
    end
  end


end
