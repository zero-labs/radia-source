

class Conflict < ActiveRecord::Base

  has_and_belongs_to_many :broadcasts, :join_table => "conflicts_broadcasts"
  belongs_to :active_broadcast, :class_name => "Broadcast"

  before_validation :set_time_boundaries

  validates_presence_of :dtstart, :dtend

  validate :start_date_is_before_end_date

  def intersects? bc
    not (bc.dtend <= self.dtstart or bc.dtstart >= self.dtend)
  end

  def add_broadcast bc
    if bc.active?
      if self.active_broadcast.nil?
        self.active_broadcast = bc 
        bc
      end
    else
      unless self.broadcasts.include? bc
        self.broadcasts << bc 
        self.broadcasts
      end
    end
  end

  def remove_broadcast bc
    unless self.active_broadcast == bc
      self.broadcasts.delete bc
    else
      self.active_broadcast = nil
    end

    if self.all_broadcasts.length <= 1
      self.destroy
      return true
    else 
      return self.save
    end
  end


  protected  

  def all_broadcasts
    #[self.active_broadcast, self.broadcasts].flatten
    [self.active_broadcast] + self.broadcasts
  end

  def set_time_boundaries
    unless self.active_broadcast.nil?
      self.dtstart = self.active_broadcast.dtstart
      self.dtend = self.active_broadcast.dtend
    else
      tmp = self.broadcasts.max{|x,y| x.dtstart <=> y.dtstart}
      self.dtstart = tmp.dtstart unless tmp.nil?
      tmp = self.broadcasts.min{|x,y| x.dtend <=> y.dtend}
      self.dtend = tmp.dtend unless tmp.nil?
    end
  end



  def update_time_boundaries bc
    if self.active_broadcast.nil?
      if self.dtstart.nil? and self.dtend.nil?
        self.dtstart = bc.dtstart
        self.dtend = bc.dtend
      else
        self.dtstart, self.dtend = Conflict::find_intersection(self.dtstart, self.dtend, bc.dtstart, bc.dtend)
      end
    else
      self.dtstart = self.active_broadcast.dtstart
      self.dtend = self.active_broadcast.dtend
    end
  end

  def self.find_intersection s1, e1, s2, e2
    return nil if e2 <= s1 or s2 >= e1
    start = s1 >= s2 ? s1 : s2
    eend = e1 <= e2 ? e1 : e2
    return start,eend
  end
  
  # Validation method.
  # Ensures that start date comes before end date
  def start_date_is_before_end_date
    return if self.dtstart.nil? or self.dtend.nil?
    errors.add(:dtend, "date/time can't be before start date/time") unless self.dtstart <= self.dtend
  end
end

