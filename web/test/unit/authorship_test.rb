require File.dirname(__FILE__) + '/../test_helper'

class AuthorshipTest < ActiveSupport::TestCase
  fixtures :users, :authorships, :programs
  
  def test_should_not_create_authorship
    assert_no_difference 'Authorship.count' do
      a = Authorship.new
      a.save
    end
  end

  def test_should_require_user
    assert_no_difference 'Authorship.count' do
      a = Authorship.new(:program => programs(:program_1))
      a.save
    end
    assert_no_difference 'Authorship.count' do
      a = Authorship.new(:program_id => programs(:program_1).id)
      a.save
    end
  end

  def test_should_require_program
    assert_no_difference 'Authorship.count' do
      a = Authorship.new(:user => users(:pepe))
      a.save
    end
    assert_no_difference 'Authorship.count' do
      a = Authorship.new(:user_id => users(:pepe).id)
      a.save
    end
  end

  def test_should_require_rules
    assert_no_difference 'Authorship.count' do
      a = Authorship.new(:program => programs(:program_1), :user => users(:pepe))
      a.save
    end
    assert_no_difference 'Authorship.count' do
      a = Authorship.new(:program_id => programs(:program_1).id, :user_id => users(:pepe).id)
      a.save
    end
  end
  
  def test_should_ensure_user_and_program_uniqueness
    a = Authorship.new(:program => programs(:program_1), :user => users(:pepe), :tuesday => true)
    a.save

    assert_no_difference 'Authorship.count' do
      a = Authorship.new(:program => programs(:program_1), :user => users(:pepe), :always => true)
      a.save
    end
  end
  
  def test_should_create_authorship
    assert_difference 'Authorship.count' do
      a = Authorship.new(:program => programs(:program_1), :user => users(:pepe), :tuesday => true)
      a.save
    end
    assert_difference 'Authorship.count' do
      a = Authorship.new(:program_id => programs(:program_2).id, :user_id => users(:pepe).id, :tuesday => true)
      a.save
    end
  end
  
  def test_should_return_all_emissions
    a = authorships(:always)
    p = programs(:program_1)
    assert_equal p.emissions.count, a.emissions.count
  end
  
  def test_should_only_return_emissions_on_certain_days
    a = authorships(:mon_tue)
    p = programs(:program_1)
    count = 0
    p.emissions.each {|e| count += 1 if ((e.dtstart.wday == 1) or (e.dtstart.wday == 2)) }
    assert_equal count, a.emissions.size
  end
  
  def test_should_return_correct_number_of_emissions
    a = authorships(:mon_tue)
    assert_equal 0, a.emissions(0).size
    assert_equal 1, a.emissions(1).size
    assert_equal 2, a.emissions(2).size
    assert_equal 3, a.emissions.size # all emissions
  end

  
  #def test_should_give_author_role_to_user
  #  assert_equal false, users(:pepe).has_role?('author')
  #  create_authorship
  #  assert_equal true, users(:pepe).has_role?('author')
  #end
  #
  #def test_should_take_author_role_from_user
  #  a = create_authorship
  #  a.destroy
  #  assert_equal false, users(:pepe).has_role?('author')
  #end
  #
  #def test_should_keep_author_role
  #  a = create_authorship
  #  b = create_authorship(:program => programs(:program_2))
  #  a.destroy
  #  assert_equal true, users(:pepe).has_role?('author')
  #end
  
  protected
  
  def create_authorship(options = {})
    defaults = { :tuesday => true, :program => programs(:program_1), :user => users(:pepe) }
    record = Authorship.new(defaults.merge(options))
    record.save
    record
  end
end
