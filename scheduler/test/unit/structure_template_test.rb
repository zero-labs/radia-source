require File.dirname(__FILE__) + '/../test_helper'

class StructureTemplateTest < ActiveSupport::TestCase
  fixtures :structure_templates, :structures

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
    et = nil
    assert_difference 'StructureTemplate.count' do
      et = create_structure_template(:color => '#123ABC')
    end
    et.destroy
    assert_difference 'StructureTemplate.count' do
      et = create_structure_template(:color => '#123456')
    end
    et.destroy
    assert_difference 'StructureTemplate.count' do
      et = create_structure_template(:color => '#ABC')
    end
    et.destroy
    assert_difference 'StructureTemplate.count' do
      et = create_structure_template(:color => '#123')
    end
  end
  
  def test_should_ensure_name_presence
    assert_no_difference 'StructureTemplate.count' do
      create_structure_template(:name => nil)
    end
  end
  
  def test_should_ensure_structure_presence
    assert_no_difference 'StructureTemplate.count' do
      create_structure_template :structure => nil
    end
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
