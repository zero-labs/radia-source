class LiveEmission < Emission
  acts_as_emission_process_configurable :live => true
  
  def emission_type
    "Live"
  end
end
