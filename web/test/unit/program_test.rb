require File.dirname(__FILE__) + '/../test_helper'

class ProgramTest < ActiveSupport::TestCase
  def test_validation
    
  end

  def test_basic_properties
    p1 = Program.new(:name => 'First program')
    p2 = Program.new(:name => 'Comunicação Típica') # program with unicode characters
    p1.save
    p2.save
    assert_equal "first-program", p1.urlname
    assert_equal "comunicacao-tipica", p2.urlname
  end
end
