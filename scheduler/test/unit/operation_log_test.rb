#require 'test_helper'
require File.dirname(__FILE__) + '/../test_helper'

class OperationLogTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_status_should_be_accessed_a_symbol
    op = OperationLog.new(:status => :initializing, 
                          :dtstart => Time.now, 
                          :dtend => 1.hour.from_now,
                          :operation_errors => 'Messages')
    assert op.save
    assert op.status.kind_of?(Symbol) 
  end
  
  def test_status_can_be_saved_as_string
    op = OperationLog.new(:status => 'initializing', 
                          :dtstart => Time.now, 
                          :dtend => 1.hour.from_now, 
                          :operation_errors => 'Messages')
    assert op.save
  end

  def test_status_create!
    assert = OperationLog.create!(:status => 'initializing',
                          :dtstart => Time.now)
  end
end
