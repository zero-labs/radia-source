class RepeatedEmission < Emission
  belongs_to :emission
  attr_protected :description
  validates_presence_of :emission
    
  def description
    self.emission.description
  end
  
  def original
    self.emission
  end
  
  def emission_type
    "Repetition"
  end
end
