require File.dirname(__FILE__) + '/../test_helper'

class EmissionTest < ActiveSupport::TestCase
  fixtures :emissions

  def test_validations
    dt1 = DateTime.new(2008, 01, 01, 12, 00)
    dt2 = DateTime.new(2008, 01, 01, 13, 00)
    dt3 = DateTime.new(2008, 01, 01, 14, 00)

    # Should have start and end date/time
    bad = Emission.new
    assert !bad.save
    assert bad.errors.invalid?(:start)
    assert bad.errors.invalid?(:end)

    # No problems should be found
    good = Emission.new(:start => dt1, :end => dt2)
    assert good.save
    assert good.errors.empty?
    
    # Start date must be unique
    bad = Emission.new(:start => dt1, :end => dt3)
    assert !bad.save
    assert bad.errors.invalid?(:start)

    # Start date/time must occur before end date/time
    bad = Emission.new(:start => dt3, :end => dt2)
    assert !bad.save
    assert bad.errors.invalid?(:end)
  end

  def test_parameters
    e = emissions(:live1)
    # Test URL parameters
    assert_equal ['2008', '01', '07', '1'], e.to_param.collect {|i| i.to_s }
  end
  
  def test_date_finders
    e1 = emissions(:live1)
    e2 = emissions(:live2)
    e3 = emissions(:live3)
    
    assert_equal 2, Emission.find_all_by_date(2008, 1).size
    assert_equal 1, Emission.find_all_by_date(2008, 2).size
    assert_equal 1, Emission.find_all_by_date(2008, 1, 14).size
  end
end
