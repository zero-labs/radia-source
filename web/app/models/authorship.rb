class Authorship < ActiveRecord::Base  
  belongs_to :program
  belongs_to :user

  after_save :update_permissions
  before_destroy :remove_permissions

  def update_permissions
    self.user.has_role('author', self.program)
    return if program.emissions.empty?
    if always?
      program.emissions.each { |e| user.has_role('author', e) }
    else
      program.emissions.each do |e|
        if permissions_by_day[e.start.wday]
          user.has_role('author', e)
        else
          user.has_no_role('author', e)
        end
      end
    end
  end
  
  def remove_permissions
    self.user.has_no_role('author', self.program)
    return if program.emissions.empty?
    program.emissions.each { |e| user.has_no_role('author', e) }
  end
  
  def user_id
    self.user.id unless user.nil?
  end
  
  def user_id=(id)
    self.user = User.find(id)
  end
  
  def program_id
    self.program.id unless program.nil?
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
