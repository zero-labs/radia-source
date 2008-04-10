require File.dirname(__FILE__) + '/../test_helper'

class RepeatedEmissionTest < ActiveSupport::TestCase
  fixtures :emissions, :programs
  
  def test_should_create_repetition
    assert_difference 'RepeatedEmission.count' do
      create_repeated
    end
  end
  
  def test_should_associate_repetition_with_first_emission
    create_repeated
    assert_equal 1, emissions(:live3).repeated_emissions.size
  end
  
  def test_should_ensure_description_does_not_change
    e = emissions(:program_2_repeat_1)
    prev = e.description
    e.description = "Try to change it"
    e.save
    assert_equal prev, e.description
  end
  
  def test_description_is_the_same_as_original_emission
    assert_equal emissions(:program_2_live_1).description, emissions(:program_2_repeat_1).description
  end
  
  protected
  
  def create_repeated(options = {}) 
    defaults = {:program => programs(:program_1), :emission => emissions(:live3), 
                :start => DateTime.new(2008, 02, 22, 21, 00), :end => DateTime.new(2008, 02, 22, 22, 00) }
    record = RepeatedEmission.new(defaults.merge(options))
    record.save
    record
  end
end
