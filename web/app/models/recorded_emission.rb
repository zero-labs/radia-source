class RecordedEmission < Emission
  acts_as_emission_process_configurable :recorded => true
  
  def emission_type
    "Recorded"
  end
end
