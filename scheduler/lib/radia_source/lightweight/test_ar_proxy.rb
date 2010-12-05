
#test fiercely copied from acts_as_list :)
require 'test/unit'

require 'rubygems'
require 'active_record'

require "#{File.dirname(__FILE__)}/init" 
NS = RadiaSource::LightWeight


ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :dummies do |t|
      t.column :name, :string
      t.column :created_at, :datetime      
      t.column :updated_at, :datetime
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Dummy < ActiveRecord::Base
end



class ARProxyTestObjectMethodsWithoutPersistence < Test::Unit::TestCase
  class DummyProxy < NS::ARProxy
    proxy_reader :fail_var
    proxy_writer :name
    proxy_reader :name
    proxy_accessor :some_var
  end

  def test_proxy_reader_without_persistent_object
    a = DummyProxy.new
    assert a.respond_to? :fail_var
    assert_equal a.fail_var, nil
  end

  def test_proxy_writer_without_persistent_object
    a = DummyProxy.new
    assert a.respond_to? :name=
    assert a.respond_to? :name
    assert_equal a.name = "test_name", "test_name"
    assert_equal a.name, "test_name"
  end

  def test_proxy_accessor_without_persistent_object
    a = DummyProxy.new

    assert a.respond_to? :some_var= and a.respond_to? :some_var
    assert_equal a.some_var = "test_name", "test_name"
    assert_equal a.some_var, "test_name"
  end

  def test_new_with_arguments
    a = DummyProxy.new(:name => "test_name", :fail_var => true, :some_var => 666)
    assert_equal a.name, "test_name"
    assert_equal a.fail_var, true
    assert_equal a.some_var, 666
  end


end

class ARProxyTestObjectMethodsWithPersistence < Test::Unit::TestCase
  class DummyProxy < NS::ARProxy
    proxy_accessor :fail_var, :name
  end

  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  def test_new_from_persistent_object
    r = Kernel::Dummy.create!(:name => "test_name")
    a = DummyProxy.new_from_persistent_object r

    assert_equal DummyProxy.proxy_class, r.class
    assert_equal a.po, r
  end

  def test_proxy_reader
    r = Kernel::Dummy.create!(:name => "test_name")
    a = DummyProxy.new_from_persistent_object r

    # if the variable really exists
    assert_same a.name, r.name

    #if it's just a proxy ghost
    assert_raise  NoMethodError do 
      a.fail_var
    end
  end

  def test_proxy_writer
    r = Kernel::Dummy.create!(:name => "some name")
    a = DummyProxy.new_from_persistent_object r

    # if the variable really exists
    a.name = "test_name"
    #assert_equal r.name, "test_name"

    #if it's just a proxy ghost
    assert_raise NoMethodError do 
      a.fail_var= true
    end
  end
end


class ARProxyTestARMethods < Test::Unit::TestCase
  class DummyProxy < NS::ARProxy
    proxy_accessor :fail_var, :name
  end

  #NOTE: Missing the Kernel namespace in the Dummy class redefinition spots
  #      errors in the set proxy class. I'm not worried about this because
  #      in rails all AR classes belong to the global namespace
  #      This is related to the word Dummy pointing to the
  #      ARProxyTestARMethods namespace and the method klass.class omits the
  #      Kernel prefix
  class Kernel::Dummy < Kernel::ActiveRecord::Base
      validates_presence_of :name
  end
  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  def test_save
      r = Kernel::Dummy.create!(:name => "some name")
      a = DummyProxy.new_from_persistent_object r

      assert_respond_to a, :save

      a.name = ""
      assert_equal a.save, false

      a.name = "other name"
      assert a.save

      # Test if the change persists
      assert_equal a.name, Dummy.find_by_name("other name").name
  end


  def test_save!
      r = Kernel::Dummy.create!(:name => "some name")
      a = DummyProxy.new_from_persistent_object r

      assert_respond_to a, :save!

      a.name = ""
      assert_raise ActiveRecord::RecordInvalid do
        a.save!
      end

      a.name = "other name"
      assert a.save!

      # Test if the change persists
      assert_equal a.name, Dummy.find_by_name("other name").name
  end

  def test_destroy
    r = Dummy.create!(:name => "some name")
    a = DummyProxy.new_from_persistent_object r

    assert_respond_to a, :destroy

    id = r.id
    a.destroy
    assert_nil Dummy.find_by_id id 
  end

end



class ARProxyTestFromProxyToAR < Test::Unit::TestCase
  class Kernel::Dummy < Kernel::ActiveRecord::Base
      validates_presence_of :name
  end
  class DummyProxy < NS::ARProxy
    proxy_accessor :fail_var, :name
    set_proxy_class Kernel::Dummy
  end

  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  def test_set_proxy_class
    assert_equal DummyProxy.proxy_class, Kernel::Dummy
  end

  def test_save!
    a = DummyProxy.new(:name => "some name")
    a.save!

    assert_not_nil a.po
    assert_equal DummyProxy.proxy_class, a.po.class
    assert_equal 1, a.po.id
    assert_equal "some name", a.po.name
  end
end
