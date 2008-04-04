class Authorship < ActiveRecord::Base  
  belongs_to :program
  belongs_to :user

  validates_presence_of :user_id, :program_id, :on => :create
  validates_presence_of :user, :program, :on => :save
  validate :must_have_some_day_rule


  # Returns the emissions in which the user is an author
  def emissions(number = -1)
    return [] if number == 0
    
    if self.always?
      return self.program.emissions.find(:all, :limit => number) if number > 0
      return self.program.emissions if number < 0
    else
      perms = permissions_by_day
      count = 0
      em = program.emissions.select { |e| perms[e.start.wday] }
      return em.slice(0, number) if number > 0
      return em if number < 0
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

  protected

  def self.weekdays
    [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
  end

  def permissions_by_day
    self.class.weekdays.collect { |d| self.send(d) }
  end

  def must_have_some_day_rule
    return true if self.always
    self.permissions_by_day.each { |p| return true if p }
    errors.add_to_base 'must indicate when the user is an author'
  end
end
