class Authorship < ActiveRecord::Base  
  belongs_to :program
  belongs_to :user

  #after_save :update_permissions
  #before_destroy :remove_permissions
  
  # Returns the emissions in which the user is an author
  def emissions(number = -1)
    if self.always?
      return self.program.emissions.find(:all, :limit => number) if number >= 0
      return self.program.emissions if number < 0
    else
      count = 0
      emission_set.select do |e| 
        count += 1
        break if count == number
        perms[e.start.wday]
      end
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
