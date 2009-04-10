class AudioAsset < ActiveRecord::Base
  has_many :segments, :dependent => :destroy
  has_many :structures, :through => :segments
  
  has_many :playlist_elements, :dependent => :destroy
  
  belongs_to :creator, :class_name => 'User'
  
  validates_presence_of :title, :unless => :authored?
  validates_uniqueness_of :title, :allow_nil => true, :allow_blank => true
  
  def unavailable?
    !self.available?
  end
  
  def authors
    r = [self.creator].compact
    self.structures.nil? ? r : self.structures.collect { |s| s.authors != [] }.concat(r).uniq
  end
end
