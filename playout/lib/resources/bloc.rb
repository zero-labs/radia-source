class Bloc < ActiveResource::Base
  # TODO self.site
  self.site = ''
  
  def to_palinsesto(builder, name, dtstart, dtend)
    bloc_elements.each_with_index do |be, i|
      be.to_palinsesto(builder, name + " (part #{i+1})", dtstart, dtend)
    end
  end
end