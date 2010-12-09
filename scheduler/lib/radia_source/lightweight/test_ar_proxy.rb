
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

    create_table :owners do |t|
      t.column :name, :string
      t.column :dummy_id, :integer
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

class Owner < ActiveRecord::Base
  belongs_to :dummy
end

class Dummy < ActiveRecord::Base
  has_one :owner
end




class ARProxyTestObjectMethodsWithoutPersistence < Test::Unit::TestCase
  class DummyProxy < NS::ARProxy
    proxy_reader :fail_var
    proxy_writer :name
    proxy_reader :name
    proxy_accessor :some_var
  end

  def test_proxy_class_method
    assert_raise NameError do
      DummyProxy.proxy_class
    end
  end
  def test_proxy_reader_without_persistent_object
    a = DummyProxy.new
    assert_respond_to a, :fail_var
    assert_equal a.fail_var, nil
  end

  def test_proxy_writer_without_persistent_object
    a = DummyProxy.new
    assert_respond_to a, :name=
    assert_respond_to a, :name
    assert_equal a.name = "test_name", "test_name"
    assert_equal a.name, "test_name"
  end

  def test_proxy_accessor_without_persistent_object
    a = DummyProxy.new

    assert_respond_to a, :some_var= and a.respond_to? :some_var
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
  class OwnerProxy < NS::ARProxy
    proxy_accessor :name
    set_proxy_class Owner
  end
  class DummyProxy < NS::ARProxy
    proxy_accessor :name
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


class ARProxyTestFromProxyToARwithOtherProxies < Test::Unit::TestCase
  class OwnerProxy < NS::ARProxy
    proxy_accessor :name, :dummy
    set_proxy_class Owner
  end

  class DummyProxy < NS::ARProxy
    proxy_accessor :owner, :name
    set_proxy_class Dummy
  end

  def setup
    setup_db
  end

  def teardown
    teardown_db
  end


  def test_save!
    a = DummyProxy.new(:name => "some name")
    a.save!
    o = OwnerProxy.new(:name => "owner's name", :dummy => a.po)
    o.save!

    assert_not_nil a.po
    assert_equal DummyProxy.proxy_class, a.po.class
    assert_equal 1, a.po.id
    assert_equal "some name", a.po.name
  end

  def test_2_save!
    a = DummyProxy.new(:name => "some name")
    o = OwnerProxy.new(:name => "owner's name", :dummy => a)
    o.save!

    assert_not_nil a.po
    assert_equal DummyProxy.proxy_class, a.po.class
    assert_equal 1, a.po.id
    assert_equal "some name", a.po.name
    assert_equal o.po, a.owner
  end

  def test_3_save!
    o = OwnerProxy.new(:name => "owner's name")
    a = DummyProxy.new(:name => "some name", :owner => o)
    o.save!
    a.save!

    assert_not_nil a.owner
    assert_equal Kernel.const_get(:Owner), a.owner.class
    assert_equal o.po, a.owner
  end
end



class TestNamespaceConflicts < Test::Unit::TestCase
  module Problematic
    class Dummy < NS::ARProxy
      proxy_accessor :owner, :name
      set_proxy_class Dummy
    end
  end

  module NonProblematic
    class Dummy < NS::ARProxy
      set_proxy_class Kernel::Dummy
    end
    class Owner < NS::ARProxy
    end
  end

  def setup
    setup_db
  end

  def teardown
    teardown_db
  end

  def test_problematic_save!
    d = Problematic::Dummy.new(:name => "some name")

    assert d.kind_of? TestNamespaceConflicts::Problematic::Dummy

    assert_raise NoMethodError do d.save!end
  end

  def test_non_problematic_save!
    d = NonProblematic::Dummy.new(:name => "some name")

    assert_kind_of TestNamespaceConflicts::NonProblematic::Dummy, d

    assert  d.save
    assert_kind_of Kernel::Dummy, d.po
  end

  def test_good_defaults_save!
    o = NonProblematic::Owner.new

    assert o.save
    assert_kind_of Kernel::Owner, o.po
  end
end
