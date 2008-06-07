class Segment < ActiveResource::Base
  
  self.site = '' # TODO
  
  def to_palinsesto(builder, position, total, description, dtstart, dtend)
    #asset = asset_instance(audio)
    self.send(asset_type).send(:to_palinsesto, builder, position, total, dtstart, dtend, description)
  end
  
  protected
  
  def asset_type
    if self.respond_to?('single')
      :single
    elsif self.respond_to?('playlist')
      :playlist
    end
  end
end