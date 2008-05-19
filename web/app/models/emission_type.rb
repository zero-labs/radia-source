class EmissionType < ActiveRecord::Base
  has_many :emissions, :dependent => :destroy
  has_many :programs, :through => :emissions, :uniq => true
  has_one :bloc, :as => :playable
  
  validates_presence_of :name, :color
  validates_uniqueness_of :name
  validates_format_of :color, :with => /(\#[[:xdigit:]]{3}$)|(\#[[:xdigit:]]{6}$)/
  validates_presence_of :bloc
  
  # To act as playable
  def duration
    nil
  end
end
