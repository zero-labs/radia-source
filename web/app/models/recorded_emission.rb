class RecordedEmission < Emission
  has_many :repeated_emissions, :foreign_key => 'emission_id', :order => 'start ASC', :dependent => :destroy
  
  acts_as_emission_process_configurable :recorded => true
  
  def emission_type
    "Recorded"
  end
end
