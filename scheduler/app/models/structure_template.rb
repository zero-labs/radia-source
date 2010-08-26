class StructureTemplate < ActiveRecord::Base  
  has_many :originals, :dependent => :destroy
  has_many :programs, :through => :originals, :uniq => true
  has_one :structure, :as => :playable, :dependent => :destroy
  
  validates_presence_of :name, :color
  validates_uniqueness_of :name
  validates_format_of :color, :with => /(\#[[:xdigit:]]{3}$)|(\#[[:xdigit:]]{6}$)/
  validates_presence_of :structure, :on => :save
  
  before_validation :add_structure_if_missing  
  
  def self.update_calendars
    
  end
  
  # To act as playable
  def length
    nil
  end
  
  protected
  
  def add_structure_if_missing
    if self.structure.nil?
      self.structure = Structure.new
    end
    true # as to not return anything else
  end
end
