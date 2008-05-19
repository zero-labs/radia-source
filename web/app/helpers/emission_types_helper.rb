module EmissionTypesHelper
  def emission_types_crumbs(type = nil)
    add_crumb("Schedule", schedule_path)
    add_crumb("Emission types", schedule_emission_types_path, (type.nil? ? true : false))
    add_crumb(type.name, schedule_emission_type_path(type), true) unless type.nil?
  end
  
  def live_assets
    options_for_select([['Select a live source...', nil]]) +
    options_from_collection_for_select(LiveSource.find(:all), :id, :title)
  end
  
  def playlist_assets
    options_for_select([['Select a playlist...', nil]]) + 
    options_from_collection_for_select(Playlist.find(:all), :id, :title)
  end
  
  def single_unauthored_assets
    options_for_select([['Select a single...', nil]]) + 
    options_from_collection_for_select(SingleAudioAsset.find(:all, 
        :conditions => ['available = ?', true]), :id, :title)
  end
  
  
  def deadline_values
    options_for_select((1..60).collect { |v| [v.to_s, v.to_s] })
  end
  
  def deadline_units
    options_for_select([['hours', 'hours'], ['minutes', 'minutes']])
  end
end
