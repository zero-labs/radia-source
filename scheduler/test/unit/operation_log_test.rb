#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class OperationLogTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_status_should_be_accessed_a_symbol
    op = OperationLog.new(:status => :initializing, 
                          :dtstart => Time.now, 
                          :dtend => 1.hour.from_now,
                          :operation_errors => 'Messages')
    assert op.save!
    assert op.status.kind_of?(Symbol) 
  end
  
  def test_status_can_be_saved_as_string
    op = OperationLog.new(:status => 'initializing', 
                          :dtstart => Time.now, 
                          :dtend => 1.hour.from_now, 
                          :operation_errors => 'Messages')
    assert op.save!
  end

  def test_string_description
    
    assert o=OperationLog.create!(:description => 'foo bar')
    assert_equal 'foo bar', o.description.to_s

    assert o=OperationLog.create!(:description => :foobar)
    assert_equal :foobar, o.description
  end

  def test_status_create!
    assert OperationLog.create!(:status => 'initializing',
                          :dtstart => Time.now)
  end

  def test_level_enumeration

    assert_raise ActiveRecord::RecordInvalid do
      OperationLog.create!(:level => :some_level)
    end

    assert o=OperationLog.create!
    assert_equal :unknown, o.level

    assert o=OperationLog.create!(:level=>:serious)
    assert_equal :serious, o.level

    assert o=OperationLog.create!(:level=>:ok)
    assert_equal :ok, o.level

    assert o=OperationLog.create!(:level=>:warning)
    assert_equal :warning, o.level
  end
end
