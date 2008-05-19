class Broadcast < ActiveRecord::Base
  extend RadiaSource::TimeUtils
  
  belongs_to :program_schedule
  
  validates_presence_of :dtstart, :dtend, :program_schedule
  
  # Ensure that start datetime comes before end datetime
  validate :start_date_is_before_end_date
  
  # Ensure that there aren't any broadcast in this timeframe
  validate :does_not_conflict_with_others
  
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
  def self.find_in_range(startdt, enddt)
    find(:all, :conditions => ["(dtstart < ? AND dtend > ?) OR (dtstart >= ? AND dtend <= ?) OR (dtstart < ? AND dtend > ?)", 
                                startdt, startdt, startdt, enddt, enddt, startdt], :order => "dtstart ASC")
  end
  
  # Find all broadcasts on a certain date
  def self.find_all_by_date(year, month = nil, day = nil)
    if !year.blank?
      from, to = self.time_delta(year, month, day)
      find(:all, :conditions => ["dtstart BETWEEN ? AND ?", from, to], :order => "dtstart ASC")
    else
      find(:all, :order => "dtstart ASC")
    end
  end
  
  def self.gaps(date_start, date_end)
    return [] if date_start >= date_end
    query =  "SELECT A.dtend as dtstart, B.dtstart as dtend "
    query << "FROM broadcasts A, broadcasts B "
    query << "WHERE A.program_schedule_id = B.program_schedule_id AND "
    query << "A.dtstart <> B.dtstart AND A.dtend <> B.dtend AND A.dtend < B.dtstart AND "
    query << "B.dtstart = (SELECT min(c.dtstart) FROM broadcasts c WHERE c.dtstart > a.dtstart) AND "
    query << "A.dtend >= ? AND B.dtstart <= ?"
    query << "order by dtstart"
    
    all_gaps(date_start, date_end, find_by_sql([query, date_start, date_end]))
  end
  
  def same_time?(other)
    (self.dtstart == other.dtstart) && (self.dtend == other.dtend)
  end
  
  def same_time?(dtstart, dtend)
    (self.dtstart == dtstart) && (self.dtend == dtend)
  end
  
  ### Instance methods
  
  # A broadcast is a gap by default. It only stops being one when it is 
  # an instance of a subclass 
  def gap?
    true
  end
  
  def <=>(other)
    self.dtstart <=> other.dtstart
  end
  
  # Broadcast duration (in seconds) as Integer 
  def duration
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
  
  def bloc
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.broadcast(:type => 'gap') do
      xml.tag!(:dtstart, self.dtstart, :type => :datetime)
      xml.tag!(:dtend, self.dtend, :type => :datetime)
    end
  end

  protected
  
  def self.all_gaps(dtstart, dtend, in_between)
    gaps = Array.new(in_between)
    if in_between.empty?
      if (broadcasts = find_in_range(dtstart, dtend)).empty?
        gaps << Broadcast.new(:dtstart => dtstart, :dtend => dtend) 
      else
        unless dtstart >= broadcasts.first.dtstart
          gaps << Broadcast.new(:dtstart => dtstart, :dtend => broadcasts.first.dtstart) 
        end
        unless broadcasts.last.dtend >= dtend 
          gaps << Broadcast.new(:dtstart => broadcasts.last.dtend, :dtend => dtend) 
        end
      end
    else
      if in_between.first.dtstart > dtstart
        before = find_in_range(dtstart, in_between.first.dtstart) 
        unless dtstart >= before.first.dtstart
          gaps.insert(0, Broadcast.new(:dtstart => dtstart, :dtend => before.first.dtstart)) 
        end
      end
      if in_between.last.dtend < dtend
        after = find_in_range(in_between.last.dtend, dtend)
        start_at = (after.empty? ? in_between.last.dtend : after.first.dtend)
        unless start_at >= dtend
          gaps.insert(-1, Broadcast.new(:dtstart => start_at, :dtend => dtend))
        end
      end
    end
    gaps
  end

  # Validation method.
  # Ensures that start date comes before end date
  def start_date_is_before_end_date
    return if self.dtstart.nil? or self.dtend.nil? # This should be caught by another validation
    errors.add(:dtend, "date/time can't be before start date/time") unless self.dtstart <= self.dtend
  end
  
  # Validation method.
  # Ensures that there aren't overlapping Broadcasts
  def does_not_conflict_with_others
    
    if Broadcast.find_in_range(dtstart, dtend).size > 0
      errors.add_to_base("There are other broadcasts within the given timeframe (#{dtstart} - #{dtend})")
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
