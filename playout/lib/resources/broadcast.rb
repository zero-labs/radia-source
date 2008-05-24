class Broadcast < ActiveResource::Base
  self.site = "#{$manager_config['base_uri']}/schedule/"
    
  def self.find_all_by_date(year, month = nil, day = nil)
    from = self.site.path + "broadcasts/#{year}"
    from << "/#{month}" unless month.nil?
    from << "/#{day}" unless day.nil?
    from += '.xml'
    
    Broadcast.find(:all, :from => from)
  end
    
  
  def to_palinsesto(builder)
    self.attributes['type'] == 'gap' ? desc = 'Gap' : desc = program_id
    bloc.to_palinsesto(builder, desc, dtstart, dtend) unless bloc.nil?
  end
end