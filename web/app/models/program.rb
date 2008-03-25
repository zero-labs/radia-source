class Program < ActiveRecord::Base
  include TimeUtils
  
  validates_uniqueness_of :name, :on => :save, :message => "must be unique"
  acts_as_urlnameable :name, :overwrite => true

  has_many :emissions, :dependent => :destroy, :order => 'start ASC'
  
  # Shorthand to retrieve upcoming emissions
  has_many :upcoming_emissions, :class_name => "Emission", 
                                :conditions => ["start >= ?", Time.now], 
                                :order => 'start ASC', 
                                :limit => 5
                                
  # Generate URLs based on the program's urlname
  def to_param
    self.urlname
  end

  # Tests if the program has an emission on a given date
  def has_emissions?(date)
    !self.find_emission_by_date(date.year, date.month, date.day).blank?
  end

  # Find all emissions on a given date
  def find_emissions_by_date(year, month = nil, day = nil)
    if !year.blank?
      from, to = TimeUtils.time_delta(year, month, day)
      emissions.find(:all, :conditions => ["start BETWEEN ? AND ?", from, to])
    else
      emissions.find(:all)
    end
  end

  # Find one emission on a given date
  def find_emission_by_date(year, month, day)
    self.find_emissions_by_date(year, month, day).first
  end
end
