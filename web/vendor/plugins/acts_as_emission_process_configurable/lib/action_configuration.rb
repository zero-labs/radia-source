class ActionConfiguration < ActiveRecord::Base  
  validates_presence_of :perform, :activity
  validate :has_some_action
  
  protected
  
  def has_some_action
    return true if !self.numerical_value.nil? or !self.string_value.nil?
    errors.add_to_base 'must have some action defined'
  end
end
