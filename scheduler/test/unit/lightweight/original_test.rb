require File.dirname(__FILE__) + '/../../test_helper'

NS=RadiaSource::LightWeight

class OrginalTest < ActiveSupport::TestCase
  fixtures :programs, :structure_templates


  def test_proxy_methods
    assert NS::Original.instance_methods.include? "program"
    assert NS::Original.instance_methods.include? "program="
    assert NS::Original.instance_methods.include? "structure_template"
    assert NS::Original.instance_methods.include? "structure_template="
  end
    
  def test_save
    t = Time.now
    original = NS::Original.new :dtstart => t, :dtend => t + 30.minutes,
      :program => Program.first,:structure_template => StructureTemplate.first

    assert original.save

    o2 = Original.find original.po.id

    assert_equal o2.program, original.program
  end

  def test_similar?
    orig1 = NS::Original.new_from_persistent_object Original.first
    orig2 = NS::Original.new_from_persistent_object Original.first

    assert orig1.similar?(orig2)

    # I expect at least 2 structure templates from fixtures!!!
    orig2.structure_template = StructureTemplate.last

    assert_not_equal orig1.structure_template, orig2.structure_template
    assert !orig1.similar?(orig2)
  end
end

