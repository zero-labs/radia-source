class Broadcast < ActiveRecord::Base
  extend RadiaSource::TimeUtils
  
  belongs_to :program_schedule
  
  #TODO: dependent destroy and similar for the following 2 lines
  belongs_to :conflict

  
  validates_presence_of :dtstart, :dtend, :program_schedule
  
  # Ensure that start datetime comes before end datetime
  validate :start_date_is_before_end_date

  # ensure that active==true and conflicts != nil do not happen
  validate :not_active_with_conflicts
  
  # Ensure that there aren't any (active) broadcasts in this timeframe
  validate :does_not_conflict_with_others

  # use after create since dtstart/dtend (so their influence on conflicts) are supposed to be 
  # unmutable.  after save is complex to use and easily takes to infinite loops
  after_create :create_conflicts
  
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

  def self.find_greater_than(startdt, user_options={})
    options = { :active => true, :program_schedule_id => 1 }.update(user_options)

    query = 'dtstart >= :dtstart'
    values= {:dtstart => startdt}

    unless options[:active].nil?
      query << " AND active = :active"
      values[:active] = options[:active]
    end

    unless options[:program_schedule_id].nil?
      query << " AND program_schedule_id=:program_schedule_id"
      values[:program_schedule_id] = options[:program_schedule_id]
    end

    ## unless active.nil?
    ##   find(:all, :conditions => ["(dtstart >= :dtstart AND active = :active)" , 
    ##        {:dtstart => startdt, :active => options[:active] } ], :order => "dtstart ASC")
    ## else
    ##   find(:all, :conditions => ["(dtstart >= ?)" , startdt], :order => "dtstart ASC")
    ## end
    find(:all, :conditions => [query, values], :order=> "dtstart ASC")
  end

  def self.find_first_sooner_than(startdt, program, user_options={})
    options = {:type=>nil, :active=>true}.update user_options

    query = "dtend < :t AND program_id = :program"
    values= {:t=>startdt, :program=>program.id} 

    unless options[:active].nil?
      query += " AND active = :active"
      values[:active] = options[:active]
    end

    unless options[:type].nil?
      query += " AND type = :type"
      values[:type] = options[:type]
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
    return nil if created_at.nil?
    return updated_at > created_at
  end

  def activate!
    self.update_attributes!(:active => true)
  end

  def activate
    b = Broadcast.find_in_range(dtstart, dtend)
    if not ( b.size > 1 or (b.size == 1 and b.first != self))
      if self.conflict.nil?
        self.active = true 
        return save!
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
  
  def not_active_with_conflicts
    if self.active and not self.conflict.nil?
      errors.add_to_base("An active broadcast cannot be active and hava a conflict")
    end
  end
  # Validation method.
  # Ensures that there aren't overlapping active Broadcasts
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
    
    tmp = Conflict.find_in_range(self.dtstart, self.dtend)

    # first we try to merge all conflicts that exist in this timeframe
    conf = Conflict.merge self, tmp

    # then we add all broadcasts that weren't conflicting previously
    bcs = Broadcast.find_in_range(dtstart, dtend, active=false).select do |bc| 
      self != bc and bc.conflict.nil?
    end


    unless bcs.empty?
      if conf.nil?
        conf = Conflict.create!
        self.conflict = conf
        #ActiveRecord::Base.connection.update_sql("UPDATE broadcasts SET conflict_id=#{conf.id} 
        #WHERE id=#{self.id};")
        #ActiveRecord::Base.connection.execute(Broadcast.send :sanitize_sql_array,
        #  ["UPDATE broadcasts SET conflict_id=? WHERE id=?;",conf.id, self.id])
        #self.update_attribute(:conflict, conf)
        
        conf.add_broadcast(self) #use only in after_create (not in after_save)
      end

      bcs.each do |bc|
        #bc.update_attribute(:conflict, conf)
        conf.add_broadcast bc
      end

      conf.save!
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
