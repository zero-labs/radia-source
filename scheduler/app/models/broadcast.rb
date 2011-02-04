class Broadcast < ActiveRecord::Base
  extend RadiaSource::TimeUtils
  
  belongs_to :program_schedule
  
  #TODO: dependent destroy and similar for the following 2 lines
  belongs_to :conflict

  
  validates_presence_of :dtstart, :dtend, :program_schedule
  
  # Ensure that start datetime comes before end datetime
  validate :start_date_is_before_end_date
  
  # Ensure that there aren't any (active) broadcasts in this timeframe
  validate :does_not_conflict_with_others

  after_save :create_conflicts
  
  ### Class methods
  
  # Checks if it has a broadcast on a given day
  def self.has_broadcasts?(date)
    !find_by_date(date.year, date.month, date.day).blank?
  end
  
  # Find one broadcast on a certain date
  def self.find_by_date(year, month, day)
    find_all_by_date(year, month, day).first
  end
  
  # Finds all broadcasts within dtstart and dtend
  def self.find_in_range(startdt, enddt, active=true)
    unless active.nil?
      find(:all, :conditions => ["program_schedule_id = :ps AND active = :active AND ((dtstart < :t1 AND dtend > :t1) OR (dtstart >= :t1 AND dtend <= :t2) OR (dtstart < :t2 AND dtend > :t1))",
           {:t1 =>startdt, :t2 => enddt, :ps => ProgramSchedule.active_instance.id, :active => active }], :order => "dtstart ASC")
    else
      find(:all, :conditions => ["(dtstart < :t1 AND dtend > :t1) OR (dtstart >= :t1 AND dtend <= :t2) OR (dtstart < :t2 AND dtend > :t1)",
           {:t1 =>startdt, :t2 => enddt}], :order => "dtstart ASC")
    end
    #find(:all, :conditions => ["(dtstart < ? AND dtend > ?) OR (dtstart >= ? AND dtend <= ?) OR (dtstart < ? AND dtend > ?)", 
    #                            startdt, startdt, startdt, enddt, enddt, startdt], :order => "dtstart ASC")
  end

  def self.find_greater_than(startdt, active=true)
    if active
      find(:all, :conditions => ["(dtstart >= :dtstart AND active = :active)" , 
           {:dtstart =>startdt, :active=>true}], :order => "dtstart ASC")
    else
      find(:all, :conditions => ["(dtstart >= ?)" , startdt], :order => "dtstart ASC")
    end

  end

  def self.find_first_sooner_than(startdt, program, type=nil, active=true)

    query = "dtend < :t AND program_id = :program"
    values= {:t=>startdt, :program=>program.id} 

    unless active.nil?
      query += " AND active = :active"
      values[:active] = active
    end

    unless type.nil?
      query += " AND type = :type"
      values[:type] = type
    end

    find(:all, :conditions => [query, values], :order => "dtstart DESC", :limit => 1)[0]

  end
  
  # Find all broadcasts on a certain date
  def self.find_all_by_date(year, month = nil, day = nil, active=true)
    if !year.blank?
      from, to = self.time_delta(year, month, day)
      find(:all, :conditions => ["dtstart BETWEEN ? AND ? AND active = ?", from, to, active], :order => "dtstart ASC")
    else
      find(:all, :order => "dtstart ASC")
    end
  end
  
  ### Instance methods
  def intersects? bc
    not (bc.dtend <= self.dtstart or bc.dtstart >= self.dtend)
  end
  
  def same_time?(other)
    (self.dtstart == other.dtstart) && (self.dtend == other.dtend)
  end
  
  def same_time?(dtstart, dtend)
    (self.dtstart == dtstart) && (self.dtend == dtend)
  end
  
  # Creates an array for params (to use the original's date)
  def to_param
    param_array
  end
  
  def <=>(other)
    self.dtstart <=> other.dtstart
  end
  
  # Broadcast duration (in seconds) as Integer 
  def length
    (self.dtend.to_time - self.dtstart.to_time).to_i
  end

  # Convenience method to access start date/time year
  def year
    self.dtstart.year
  end

  # Convenience method to access start date/time month
  def month
    self.dtstart.month
  end

  # Convenience method to access start date/time day
  def day
    self.dtstart.day
  end

  # Convenience method to access start date/time hour
  def hour
    self.dtstart.hour
  end

  # Convenience method to access start date/time minute
  def minute
    self.dtstart.min
  end

  # Was the broadcast edited after creation? TODO: dirty bit
  def dirty?
    return false if created_at.nil?
    return updated_at > created_at
  end

  def activate!
    self.update_attributes!(:active => true)
  end

  def activate
    b = Broadcast.find_in_range(dtstart, dtend)
    if not ( b.size > 1 or (b.size == 1 and b.first != self))
      if self.conflicts.empty?
        self.active = true 
        save!
        return true
      else
        # TODO: something is not running correctly: If there are active
        # broadcasts, the conflicts variable shouldnt be empty
        return false
      end
    end
    false
  end

  def pp
    "#{dtstart}-#{dtend} :: "
  end

  protected

  # Validation method.
  # Ensures that start date comes before end date
  def start_date_is_before_end_date
    return if self.dtstart.nil? or self.dtend.nil? # This should be caught by another validation
    errors.add(:dtend, "date/time can't be before start date/time") unless self.dtstart <= self.dtend
  end
  
  # Validation method.
  # Ensures that there aren't overlapping Broadcasts
  def does_not_conflict_with_others
    #b = Broadcast.find_in_range(dtstart, dtend).select {|x| x.program_schedule.active }
    b = Broadcast.find_in_range(dtstart, dtend)
    if (b.size > 1) or (b.size == 1 and b.first != self)
      if active 
        errors.add_to_base("There are other broadcasts within the given timeframe (#{dtstart} - #{dtend})")
      end
    end
  end

  # callback after create

  def create_conflicts

    Broadcast.find_in_range(dtstart, dtend, active=nil).each do |bc| 
      next if self == bc
      self.add_new_conflicting_broadcast bc
    end

    # Activate by default code:
    #if self.conflicts.empty?
    #  self.active = true
    #  self.class.update_all({:active => true},{:id => self.id})
    #end

  end


  # if I'm an active broadcast the conflicting broadcast will be
  # added to the main_conflict broadcast list. Otherwise, search
  def add_new_conflicting_broadcast bc
    if bc.active?
      if bc.main_conflict.nil?
        bc.main_conflict = Conflict.new
      end
      bc.main_conflict.add_broadcast(self)
      bc.main_conflict.save!
    else

      tmp = bc.conflicts.detect { |c| c.intersects? self }

      if tmp.nil?
        # He doesn't have a conflict that intersects me? What if I have any
        # conflict that intersects him?
        tmp = self.conflicts.detect { |c| c.intersects? bc }

        # Humm... not? so it must be a new conflict...
        if tmp.nil?
          tmp = Conflict.new
          tmp.add_broadcast(bc)
          tmp.add_broadcast(self) 
        else
          tmp.add_broadcast(bc)
        end
      else
        tmp.add_broadcast(self)
      end
      tmp.save!
    end
  end



  def param_array
    @param_array ||=
    returning([year, sprintf('%.2d', month), sprintf('%.2d', day), id]) do |params|
      this = self
      k = class << params; self; end
      k.send(:define_method, :to_s) { params[-1] }
    end
  end
  
end
