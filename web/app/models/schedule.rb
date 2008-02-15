class Schedule < ActiveRecord::Base
  
  def calendar=(icalendar)
    # TODO:
    # save file to disk
    # create new version
    calendars = Icalendar.parse(icalendar)
    calendars.each do |cal|
      cal.events.each do |event|
        p = Program.find_or_create_by_name(event.summary)
        p.active = true
      end
    end
  end
  
end
