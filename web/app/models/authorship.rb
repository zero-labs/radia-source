class Authorship < ActiveRecord::Base  
  belongs_to :program
  belongs_to :user

  #after_save :update_permissions
  #before_destroy :remove_permissions
  
  # Returns the emissions in which the user is an author
  def emissions
    if self.always?
      self.program.emissions
    else
      # TODO check if self.program.emissions.empty?
      self.program.emissions.select { |e| perms[e.start.wday] }  
    end
  end
  
  # Faux accessors to support direct creation/update from form
  def user_id
    self.user.id unless user.nil?
  end
  
  def user_id=(id)
    self.user = User.find(id)
  end
  
  def program_id
    self.program.id unless self.program.nil?
  end
  
  def program_id=(id)
    self.program = Program.find(id)
  end

  private

  def self.weekdays
    [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
  end

  def permissions_by_day
    self.class.weekdays.collect { |d| self.send(d) }
  end
end
