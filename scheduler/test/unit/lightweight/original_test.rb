require File.dirname(__FILE__) +'/test_helper'


#module NS

class LOrginalTest < NS::TestCase
  fixtures :programs, :structure_templates, :broadcasts

  def teste_ensure_proxy_class
    assert_equal Kernel.const_get(:Original), NS::Original.proxy_class
  end

  def test_proxy_methods
    assert NS::Original.instance_methods.include? "program"
    assert NS::Original.instance_methods.include? "program="
    assert NS::Original.instance_methods.include? "structure_template"
    assert NS::Original.instance_methods.include? "structure_template="
  end

  def test_save
    t = Time.now
    original = NS::Original.new :dtstart => t, :dtend => t + 30.minutes,
      :program => programs(:program_1) ,:structure_template => structure_templates(:recorded)
    assert original.save!

    o2 = Kernel::Original.find original.po.id

    assert_equal o2.program, original.program
  end

  def test_similar?
    orig1 = NS::Original.new_from_persistent_object(bbroadcasts(:original1))
    orig2 = NS::Original.new_from_persistent_object(bbroadcasts(:original1))


    assert orig1.similar?(orig2)
    assert_not_same orig2, orig1

    orig2 = NS::Original.new_from_persistent_object(broadcasts(:original2))
    orig2.structure_template = structure_templates(:live) 

    assert_not_equal orig1.structure_template, orig2.structure_template
    assert !orig1.similar?(orig2)
  end

  def bbroadcasts *arg
    self.send :broadcasts, arg
  end
end
#end
