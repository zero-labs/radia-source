class ScheduleVersion < ActiveRecord::Base
  has_many :program_schedulings
  has_many :programs, :through => :program_schedulings

  #validates_presence_of :calendar, :on => :create
  before_destroy :remove_file
  
  # Virtual attribute which indexes events in the calendar through the UID
  attr_reader :events

  URI_PREFIX = 'file://'

  def calendar=(icalendar)
    @events = Hash.new
    # Save file and set uri
    # Create programs based on events in the calendar
    calendars = Vpim::Icalendar.decode(icalendar)
    icalendar.rewind # Rewind the IO stream
    self.local_file = icalendar 
    calendars.each do |cal|
      cal.components(Vpim::Icalendar::Vevent) do |event|
        p = Program.find_or_create_by_name(event.summary)
        # Create scheduling for this event
        ps = ProgramScheduling.new(:program => p,
                                   :start => event.dtstart, 
                                   :end => event.dtend, 
                                   :uid => event.uid)
        self.program_schedulings << ps
        @events[event.uid] = event
      end
    end
  end
  
  private

  def remove_file
    File.delete(self.uri.sub(URI_PREFIX, ''))
  end

  def local_file=(incoming)
    path = "#{RAILS_ROOT}/calendars/" + UUID.timestamp_create.to_s + ".ics"
    File.open(path, "w") do |file|
      file.write(incoming.read)
    end
    self.uri = URI_PREFIX + path
  end
end
