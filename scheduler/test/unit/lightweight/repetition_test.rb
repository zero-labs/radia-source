require File.dirname(__FILE__) + '/../../test_helper'

NS=RadiaSource::LightWeight

class RepetitionTest < ActiveSupport::TestCase
  fixtures :programs, :structure_templates, :structures, :broadcasts

  def test_proxy_methods
    assert NS::Repetition.instance_methods.include? "original"
    assert NS::Repetition.instance_methods.include? "original="
  end


  def test_save
    t = Time.now
    orig = NS::Original.new_from_persistent_object Kernel::Original.first

    rep = NS::Repetition.new :dtstart => t, :dtend => t+30.minutes,
      :original => orig
    
    assert rep.save
    assert orig.po.repetitions.include? rep.po

    assert tmp=Kernel::Repetition.find(rep.po.id)

  end


  def test_dirty?
    t = Time.now
    orig = NS::Original.new(:dtstart => t, :dtend => t + 30.minutes,
                             :program => Program.first,
                             :structure_template  => StructureTemplate.first)
    rep = NS::Repetition.new(:dtstart => t + 1.day, :dtend => t + (1.1).days,
                            :original => orig)

    assert !rep.dirty?
    assert rep.save
    
    orig.po.description = "Not a virgin anymore"

    assert rep.dirty?
  end

end
