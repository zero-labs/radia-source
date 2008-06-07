class Bloc < ActiveResource::Base
  # TODO self.site
  self.site = ''
  
  def to_palinsesto(builder, name, dtstart, dtend)
    segments.each_with_index do |s, i|
      s.to_palinsesto(builder, i, segments.size, name, dtstart, dtend)
    end
  end
end