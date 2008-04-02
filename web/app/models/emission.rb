class Emission < ActiveRecord::Base
  include TimeUtils
  
  acts_as_authorizable
  
  belongs_to :program_schedule
  belongs_to :program
  
  validates_uniqueness_of :start, :on => :save # Ensures unique starting datetimes
  validates_presence_of :start, :end, :on => :save
  
  validate :start_before_end
  
  # TODO validate nested emissions?

  def year
    self.start.year
  end

  def month
    self.start.month
  end

  def day
    self.start.day
  end

  def to_param
    param_array
  end

  # Find all emissions on a certain date
  def self.find_all_by_date(year, month = nil, day = nil)
    if !year.blank?
      from, to = TimeUtils.time_delta(year, month, day)
      self.find(:all, :conditions => ["start BETWEEN ? AND ?", from, to], :order => "start ASC")
    else
      Emission.find(:all, :order => "start ASC")
    end
  end

  # Find one emission on a certain date
  def self.find_by_date(year, month, day)
    find_all_by_date(year, month, day).first
  end
  
  # Checks if it has emissions on a given day
  def self.has_emissions?(date)
    !self.find_by_date(date.year, date.month, date.day).blank?
  end
  
  protected
  
  # Ensures that start date comes before end date
  def start_before_end
    return if self.start.nil? or self.end.nil? # This should be caught by another validation
    errors.add(:end, "date/time can't be before start date/time") unless self.start <= self.end
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
