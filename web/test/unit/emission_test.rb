require File.dirname(__FILE__) + '/../test_helper'

class EmissionTest < ActiveSupport::TestCase
  fixtures :emissions
  
  def test_should_require_start_and_end_date
    assert_no_difference 'Emission.count' do
      create_emission(:start => nil, :end => nil)
      create_emission(:start => nil)
      create_emission(:end => nil)
    end
  end
  
  def test_should_require_program
    assert_no_difference 'Emission.count' do
      create_emission(:program => nil)
    end
  end
  
  def test_should_ensure_start_before_end
    assert_no_difference 'Emission.count' do
      create_emission(:start => DateTime.new(2008, 01, 01, 14, 00), :end => DateTime.new(2008, 01, 01, 13, 00))
    end
  end
  
  def test_should_ensure_start_date_uniqueness
    create_emission
    assert_no_difference 'Emission.count' do
      create_emission # to create an emission at the same time
    end
  end
  
  def test_should_create_emission
    assert_difference 'Emission.count' do
      create_emission
    end
  end

  def test_url_parameters
    e = emissions(:live1)
    # Test URL parameters
    assert_equal ['2008', '01', '07', '1'], e.to_param.collect {|i| i.to_s }
  end
  
  def test_date_shorthand_parameters
    e = emissions(:live1)
    assert_equal e.start.year, e.year
    assert_equal e.start.month, e.month
    assert_equal e.start.day, e.day
  end
  
  def test_date_finders
    
    assert_equal 2, Emission.find_all_by_date(2008, 1).size
    assert_equal 2, Emission.find_all_by_date(2008, 2).size
    assert_equal 1, Emission.find_all_by_date(2008, 1, 14).size
    assert_equal true, Emission.has_emissions?(DateTime.new(2008, 01, 14))
  end
  
  protected
  
  def create_emission(options = {})
    opts = {:start => DateTime.new(2008, 01, 01, 12, 00), :end => DateTime.new(2008, 01, 01, 13, 00), 
            :program => programs(:program_1)}.merge(options)
    record = Emission.new(opts)
    record.save
    record
  end
end
