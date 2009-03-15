module StructureTemplatesHelper
  def structure_templates_crumbs(type = nil)
    add_crumb("Schedule", schedule_path)
    add_crumb("Broadcast Structure Templates", schedule_structure_templates_path, (type.nil? ? true : false))
    add_crumb(type.name, schedule_structure_template_path(type), true) unless type.nil?
  end
  
  def live_assets
    options_for_select([['Select a live source...', nil]]) +
    options_from_collection_for_select(LiveSource.find(:all), :id, :name)
  end
  
  def playlist_assets
    options_for_select([['Select a playlist...', nil]]) + 
    options_from_collection_for_select(Playlist.find(:all), :id, :title)
  end
  
  def single_unauthored_assets
    options_for_select([['Select a single...', nil]]) + 
    options_from_collection_for_select(Single.find(:all, 
        :conditions => ['authored = ?', false]), :id, :title)
  end
  
  
  def deadline_values
    options_for_select((1..60).collect { |v| [v.to_s, v.to_s] })
  end
  
  def deadline_units
    options_for_select([['hours', 'hours'], ['minutes', 'minutes']])
  end
end
