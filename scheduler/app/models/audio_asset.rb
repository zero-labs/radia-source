class AudioAsset < ActiveRecord::Base
  has_many :segments, :dependent => :destroy
  has_many :blocs, :through => :segments
  
  has_many :playlist_elements, :dependent => :destroy
  
  validates_presence_of :title, :unless => :authored?
  validates_uniqueness_of :title, :allow_nil => true, :allow_blank => true
  
  def unavailable?
    !self.available?
  end
end
