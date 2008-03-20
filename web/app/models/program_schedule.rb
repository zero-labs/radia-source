class ProgramSchedule < ActiveRecord::Base
  include ActiveRecord::Singleton
  
  has_many :emissions
  has_many :programs, :through => :emissions

  

end
