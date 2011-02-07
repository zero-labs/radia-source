

class Conflict < ActiveRecord::Base

  has_many :broadcasts

  before_validation :set_time_boundaries

  validates_presence_of :dtstart, :dtend, :if => Proc.new {|c| c.broadcasts.length > 0} 
  validate :start_date_is_before_end_date


  def self.find_in_range(startdt, enddt)
    Conflict.find(:all, :conditions => ["NOT (dtend <= :t1 OR dtstart >= :t2)", {:t1 =>startdt, :t2 => enddt}], :order => "dtstart ASC")
  end

  def self.merge(bc, conflicts)
    if conflicts.length > 0
      # first conflict is reused. Others are dumped
      # all of their broadcasts are moved to the first

      fc = conflicts.first

      conflicts.drop(1).each do |c|
        c.broadcasts.each {|b| fc.add_broadcast b}
        c.destroy 
      end
      fc.add_broadcast bc
      return fc
    else
      return nil
    end
  end

  def intersects? bc
    not (bc.dtend <= self.dtstart or bc.dtstart >= self.dtend)
  end

  def add_broadcast bc
    unless self.broadcasts.include? bc
      self.broadcasts << bc 
    end
    self.broadcasts
  end



  protected  

  def set_time_boundaries
    tmp = self.broadcasts.min{|x,y| x.dtstart <=> y.dtstart}
    self.dtstart = tmp.dtstart unless tmp.nil?
    tmp = self.broadcasts.max{|x,y| x.dtend <=> y.dtend}
    self.dtend = tmp.dtend unless tmp.nil?
  end
  
  # Validation method.
  # Ensures that start date comes before end date
  def start_date_is_before_end_date
    return if self.dtstart.nil? or self.dtend.nil?
    errors.add(:dtend, "date/time can't be before start date/time") unless self.dtstart <= self.dtend
  end
end

