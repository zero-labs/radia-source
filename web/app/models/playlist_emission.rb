class PlaylistEmission < Emission
  acts_as_emission_process_configurable :playlist => true
  
  def emission_type
    "Playlist"
  end
end
