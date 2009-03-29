require File.dirname(__FILE__) + '/../test_helper'

class StructureTemplateTest < ActiveSupport::TestCase

  def test_should_ensure_correct_color_string_format
    assert_no_difference 'StructureTemplate.count' do
      create_structure_template(:color => '#12')
    end
    assert_no_difference 'StructureTemplate.count' do
      create_structure_template(:color => '12')
    end
    assert_no_difference 'StructureTemplate.count' do
      create_structure_template(:color => '#1234')
    end
    assert_no_difference 'StructureTemplate.count' do
      create_structure_template(:color => '#123456A')
    end

    assert_difference 'StructureTemplate.count' do
      create_structure_template(:name => 'Recorded_t1', :color => '#123ABC')
    end

    assert_difference 'StructureTemplate.count' do
      create_structure_template(:name => 'Recorded_t2', :color => '#123456')
    end

    assert_difference 'StructureTemplate.count' do
      create_structure_template(:name => 'Recorded_t3', :color => '#ABC')
    end

    assert_difference 'StructureTemplate.count' do
      create_structure_template(:name => 'Recorded_t4', :color => '#123')
    end
  end
    
  def test_should_ensure_name_presence
    assert_no_difference 'StructureTemplate.count' do
      create_structure_template(:name => nil)
    end
  end
  
  def test_should_ensure_structure_presence
    assert_difference 'StructureTemplate.count' do
      create_structure_template :structure => nil
    end
    
    e = create_structure_template :structure => nil, :name => 'Another'
    assert_not_nil e.structure
  end
  
  def test_should_ensure_name_uniqueness
    assert_no_difference 'StructureTemplate.count' do
      create_structure_template :name => 'Recorded'
    end
  end
  
  def test_should_create_structure_template
    assert_difference 'StructureTemplate.count' do
      create_structure_template
    end
  end
  
  protected 
  
  def create_structure_template(opts = {})
    defaults = { :name => 'Recorded_1', :color => '#333', :structure => structures(:recorded_structure) }
    record = StructureTemplate.new(defaults.merge(opts))
    record.save
    record
  end
end
