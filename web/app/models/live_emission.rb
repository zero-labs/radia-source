class LiveEmission < Emission
  has_many :repeated_emissions, :foreign_key => 'emission_id', :order => 'start ASC', :dependent => :destroy
  
  acts_as_emission_process_configurable :live => true
  
  def emission_type
    "Live"
  end
end
