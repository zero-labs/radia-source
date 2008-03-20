class Program < ActiveRecord::Base
  validates_uniqueness_of :name, :on => :save, :message => "must be unique"
  
  acts_as_urlnameable :name, :overwrite => true
  
  def to_param
    self.urlname
  end
end
