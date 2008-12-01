class EmissionType < ActiveRecord::Base  
  has_many :emissions, :dependent => :destroy
  has_many :programs, :through => :emissions, :uniq => true
  has_one :bloc, :as => :playable, :dependent => :destroy
  
  validates_presence_of :name, :color
  validates_uniqueness_of :name
  validates_format_of :color, :with => /(\#[[:xdigit:]]{3}$)|(\#[[:xdigit:]]{6}$)/
  validates_presence_of :bloc, :on => :save
  
  before_validation :add_bloc_if_missing  
  
  # To act as playable
  def length
    nil
  end
  
  protected
  
  def add_bloc_if_missing
    if self.bloc.nil?
      self.bloc = Bloc.new
    end
    true # as to not return anything else
  end
end
