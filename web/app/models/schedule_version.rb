class ScheduleVersion < ActiveRecord::Base
  has_many :program_schedulings
  has_many :programs, :through => :program_schedulings
  
  def calendar=(icalendar)
    # Save file and set uri
    local_file = icalendar
    # Create programs based on events in the calendar
    calendars = Icalendar.parse(icalendar)
    calendars.each do |cal|
      cal.events.each do |event|
        p = Program.find_or_create_by_name(event.summary)
        p.active = true
        # Create scheduling for this event
        ps = ProgramScheduling.new(:program => p,
                                   :start => event.dtstart, 
                                   :end => event.dtend, 
                                   :recurrence => event.recurrence_rules.to_s)
        self.program_schedulings << ps
      end
    end
  end
  
  private
  
  def local_file=(incoming)
    uri = "/tmp" + UUID.timestamp_create + ".ics"
    File.open(uri, "w") do |file|
      file.write(incoming.read)
    end
    self.uri = "file://" + uri
  end
end
