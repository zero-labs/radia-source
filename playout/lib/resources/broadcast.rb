class Broadcast < ActiveResource::Base
  self.site = "#{$playout_config['base_uri']}/schedule/"
    
  def self.find_all_by_date(year, month = nil, day = nil)
    from = self.site.path + "broadcasts/#{year}"
    from << "/#{month}" unless month.nil?
    from << "/#{day}" unless day.nil?
    from += '.xml'
    
    Broadcast.find(:all, :from => from)
  end
  
  def fill_gap
    segment = { :playlist => make_playlist(dtend - dtstart) }
    Bloc.new.load(:segments => [segment])
  end
  
  def to_palinsesto(builder)
    self.attributes['type'] == 'gap' ? desc = 'Gap' : desc = program_id
    if !self.respond_to?(:bloc) or bloc.nil?
      fill_gap.to_palinsesto(builder, desc, dtstart, dtend)
    else
      bloc.to_palinsesto(builder, desc, dtstart, dtend)
    end
  end
  
  protected
  
  def make_playlist(length)
    playlist = { :id => 1, :playlist_elements => [] }
    
    playlist = add_spots(playlist, 3*60)
    
    if length > 3*60
      playlist = add_singles(playlist)
    end
  end
  
  def add_singles(playlist)
    items = SingleAudioAsset.find(:all)
    
    items.each_with_index do |item, i|
      element = { :position => i, :single => { :type => 'single', :id => item.id_at_source } }
      playlist[:playlist_elements] << element
    end
    playlist
  end
  
  def add_spots(playlist, length)
    items = SpotAudioAsset.find(:all)
    
    if dtstart.min == 0 and dtstart.sec == 0
      add_time_anouncement
    end      
  end
  playlist
end