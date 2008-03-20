require File.join(File.dirname(__FILE__), '../spec_helper')
require File.join(File.dirname(__FILE__), '../singleton_spec_helper')
require File.join(File.dirname(__FILE__), '../app')

describe "An ActiveRecord::Singleton class (in general)" do
  include ActiveRecordSingletonSpecHelper

  before(:each) { reset_singleton Thing }

  it "should only create one instance" do
    Thing.instance.should equal(Thing.instance)
  end
  
  it "should not be able to create instances via new" do
    lambda { Thing.instance.new }.should raise_error(NoMethodError)
  end

  it "should not be able to destroy the instance" do
    lambda { Thing.instance.destroy }.should raise_error(NoMethodError)
  end
end

describe "An ActiveRecord::Singleton class (with an empty table)" do
  include ActiveRecordSingletonSpecHelper
  
  before(:each) { reset_singleton Thing }

  it "should insert a single row when getting the instance" do
    Thing.count.should == 0
    Thing.instance
    Thing.count.should == 1
  end
end

describe "An ActiveRecord::Singleton class (with a row in its table)" do
  include ActiveRecordSingletonSpecHelper

  before(:each) do
    reset_singleton Thing
    Thing.connection.execute "INSERT into #{Thing.table_name} SET name = 'fred'"
  end
  
  it "should find the single row when getting the instance" do
    Thing.count.should == 1
    Thing.instance.name.should == 'fred'
  end

  it "should only have one row in table after multiple saves" do
    3.times do
      Thing.instance.save
      Thing.count.should == 1
    end
  end
  
  it "should get the instance via find" do
    Thing.find(:first).should equal(Thing.instance)
  end
  
  it "should get the instance in an array via find(:all)" do
    all = Thing.find(:all)
    all.length.should == 1
    all.first.should equal(Thing.instance)
  end
  
  it "should not find the instance when conditions don't match" do
    Thing.find(:first, :conditions => {:name => 'wilma'}).should equal(nil)
  end

  it "should return empty array with find(:all) when conditions don't match" do
    Thing.find(:all, :conditions => {:name => 'wilma'}).should == []
  end
  
  it "should update the attributes of the instance when finding" do
    Thing.instance.name = "wilma" # not saved
    Thing.find(:first).name.should == "fred"
    Thing.instance.name.should == "fred"
  end
end

# These tests use a modified Singleton class with a delay between the select
# and insert for creating a new singleton row, see fixtures/delayed_thing.rb
describe "An ActiveRecord::Singleton class (multithreaded usage)" do
  include ActiveRecordSingletonSpecHelper
  
  before(:each) { reset_singleton Thing }
    
  it "should instantiate the same object with multiple threads" do
    instances = []
    threads = (1..3).to_a.collect { Thread.new { instances << Thing.instance } }
    threads.each {|thread| thread.join}
    instances.each {|i| i.should equal(Thing.instance) }
  end
  
  it "should insert only one row with multiple threads" do
    Thing.count.should == 0
    threads = (1..3).to_a.collect { Thread.new { Thing.instance } }
    threads.each {|thread| thread.join }
    Thing.count.should == 1   
  end
end

describe "An ActiveRecord::Singleton class (concurrent usage)" do  
  include ActiveRecordSingletonSpecHelper

  it "should instantiate only one when concurrent processes get instance" do
    reset_singleton Thing
    Thing.count.should == 0
    system("#{File.dirname(__FILE__)}/../concurrent_get_instance > /dev/null").should be_true
  end
end