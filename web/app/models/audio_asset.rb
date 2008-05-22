class AudioAsset < ActiveRecord::Base
  has_many :bloc_elements
  has_many :blocs, :through => :bloc_elements
  
  has_many :playlist_elements, :dependent => :destroy
  
  validates_presence_of :title, :unless => :authored?
  validates_uniqueness_of :title, :allow_nil => true, :allow_blank => true
  
  def self.fill(length)
    find(:first)
  end
end
