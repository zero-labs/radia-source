require File.dirname(__FILE__) + '/../test_helper'

class EmissionTest < ActiveSupport::TestCase
  fixtures :broadcasts, :emission_types
  
  def test_should_require_program
    assert_no_difference 'Emission.count' do
      create_emission(:program => nil)
    end
  end
  
  def test_should_require_emission_type
    assert_no_difference 'Emission.count' do
      create_emission :emission_type => nil
    end
  end
  
  def test_should_create_emission
    assert_difference 'Emission.count' do
      create_emission
    end
  end
  
  def test_should_be_modified
    e = broadcasts(:live1)
    assert_equal false, e.modified?
    e.description = "changed!"
    assert_equal true, e.modified?
  end
  
  protected
  
  def create_emission(options = {})
    defaults = {:dtstart => DateTime.new(2008, 01, 01, 12, 00), :dtend => DateTime.new(2008, 01, 01, 13, 00), 
                :program => programs(:program_1), :emission_type => emission_types(:live), 
                :program_schedule => ProgramSchedule.instance}
    record = Emission.new(defaults.merge(options))
    record.save
    record
  end
end
