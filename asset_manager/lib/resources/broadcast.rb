class Broadcast < ActiveResource::Base
  self.site = 'http://localhost:3000/schedule/'
  
  def to_broadcast(builder)
    builder.broadcast do
      builder.start(dtstart.strftime("%Y-%m-%d %H:%M"))
      builder.stop(dtend.strftime("%Y-%m-%d %H:%M"))
    end
  end
end