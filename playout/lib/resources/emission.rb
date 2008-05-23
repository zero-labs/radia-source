class Emission < ActiveResource::Base
  # TODO self.site
  
  def to_broadcast(builder)
    builder.broadcast do
      bloc.to_broadcast(builder, self.program.name, self.dtstart, self.dtend)
    end
  end
end