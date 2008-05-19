require File.dirname(__FILE__) + '/../test_helper'

class EmissionTypeTest < ActiveSupport::TestCase
  fixtures :emission_types, :blocs

  def test_should_ensure_correct_color_string_format
    assert_no_difference 'EmissionType.count' do
      create_emission_type(:color => '#12')
    end
    assert_no_difference 'EmissionType.count' do
      create_emission_type(:color => '12')
    end
    assert_no_difference 'EmissionType.count' do
      create_emission_type(:color => '#1234')
    end
    assert_no_difference 'EmissionType.count' do
      create_emission_type(:color => '#123456A')
    end
    et = nil
    assert_difference 'EmissionType.count' do
      et = create_emission_type(:color => '#123ABC')
    end
    et.destroy
    assert_difference 'EmissionType.count' do
      et = create_emission_type(:color => '#123456')
    end
    et.destroy
    assert_difference 'EmissionType.count' do
      et = create_emission_type(:color => '#ABC')
    end
    et.destroy
    assert_difference 'EmissionType.count' do
      et = create_emission_type(:color => '#123')
    end
  end
  
  def test_should_ensure_name_presence
    assert_no_difference 'EmissionType.count' do
      create_emission_type(:name => nil)
    end
  end
  
  def test_should_ensure_bloc_presence
    assert_no_difference 'EmissionType.count' do
      create_emission_type :bloc => nil
    end
  end
  
  def test_should_ensure_name_uniqueness
    assert_no_difference 'EmissionType.count' do
      create_emission_type :name => 'Recorded'
    end
  end
  
  def test_should_create_emission_type
    assert_difference 'EmissionType.count' do
      create_emission_type
    end
  end
  
  protected 
  
  def create_emission_type(opts = {})
    defaults = { :name => 'Recorded_1', :color => '#333', :bloc => blocs(:recorded_bloc) }
    record = EmissionType.new(defaults.merge(opts))
    record.save
    record
  end
end
