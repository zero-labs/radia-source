require File.dirname(__FILE__) + '/../test_helper'

class ProgramTest < ActiveSupport::TestCase
  
  def test_should_find_correct_first_original_before_date
    found = programs(:program_2).find_first_original_before_date(DateTime.new(2008, 03, 03, 03, 00))
    assert_equal broadcasts(:program_2_live_1), found
    
    found = programs(:program_2).find_first_original_before_date(DateTime.new(2008, 03, 04, 04, 00))
    assert_equal broadcasts(:program_2_live_1), found
    
    found = programs(:program_2).find_first_original_before_date(DateTime.new(2008, 03, 04, 05, 00))
    assert_equal broadcasts(:program_2_recorded_1), found
  end

  def test_should_create_correct_urlnames
    p1 = Program.new(:name => 'First program')
    p2 = Program.new(:name => 'Comunicação Típica') # program with unicode characters
    p1.save
    p2.save
    assert_equal "first-program", p1.urlname
    assert_equal "comunicacao-tipica", p2.urlname
  end
end
