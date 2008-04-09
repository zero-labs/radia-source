class ProgramSchedule < ActiveRecord::Base
  include ActiveRecord::Singleton # Forces single record for this model
  include TimeUtils

  has_many :emissions, :order => 'start ASC'
  has_many :programs, :through => :emissions
  
  has_many :recorded_emissions, :order => 'start ASC', :conditions => ["active = ?", true]
  has_many :live_emissions, :order => 'start ASC', :conditions => ["active = ?", true]
  has_many :playlist_emissions, :order => 'start ASC', :conditions => ["active = ?", true]
  
  has_many :inactive_emissions, :order => 'start ASC', :class_name => 'Emission', :conditions => ["active = ?", false]

  acts_as_emission_process_configurable :recorded => true

  def update_emissions(params)
    #dtstart = TimeUtils.get_datetime(params[:start])
    dtstart = Time.now
    dtend = TimeUtils.get_datetime(params[:end])
    ignored = []
    params[:calendars].each_key do |key|
      next if params[:calendars][key].blank? 
      ignored << update_by_type(key.to_sym, params[:calendars][key], dtstart, dtend)
    end    
    self.save
    ignored
  end
  
  def parent
    nil
  end

  protected

  # Updates the schedule for a given type of emission
  # with events occurring between dtstart and dtend
  def update_by_type(type, icalendar, dtstart, dtend)
    return if icalendar.nil? or icalendar.blank?
    
    calendars = Vpim::Icalendar.decode(icalendar)
    return if calendars.blank?
    
    # Cleans emissions within the given timeframe
    # Destroys unaltered emissions and inactivates those with changes
    purge_emissions(type, dtstart, dtend)
    
    ignored = []
    
    calendars.each do |cal|
      cal.components(Vpim::Icalendar::Vevent) do |event|
        # TODO create recurrence object
        program = Program.find_by_name(event.summary)
        if program then
          event.occurences.each(dtend) do |occurrence|
            if occurrence >= dtstart then
              deal_with_occurrence(type, program, event, occurrence)
            end
          end
        else
          ignored << event.summary
        end
      end
    end
    ignored
  end
  
  def deal_with_occurrence(type, program, event, occurrence)
    emissions = program.find_emissions_by_date(occurrence.year, occurrence.month, occurrence.day)
    
    if emissions then
      emissions.each do |e|
        return if (e.start == occurrence) and !e.modified?
      end
    end
    # if it got here it's because the emission is different from existing ones
    create_emission(type, program, occurrence, occurrence + event.duration)
  end
  
  # Emission type, start and end date/time
  def create_emission(type, program, dtstart, dtend)
    case type
    when :recorded
      e = RecordedEmission.new(:start => dtstart, :end => dtend, :program => program, :program_schedule => self)
      self.recorded_emissions << e
    when :live
      e = LiveEmission.new(:start => dtstart, :end => dtend, :program => program, :program_schedule => self)
      self.live_emissions << e
    when :playlist
      e = PlaylistEmission.new(:start => dtstart, :end => dtend, :program => program, :program_schedule => self)
      self.playlist_emissions << e
    end
    e.save
  end
  
  def purge_emissions(type, dtstart, dtend)
    case type
    when :recorded
      k = self.recorded_emissions(true)
    when :live
      k = self.live_emissions(true)
    when :playlist
      k = self.playlist_emissions(true)
    end
    
    k.each do |e|
      # destroy if not modified and between start/end dates
      e.destroy if (!e.modified? and (e.start >= dtstart) and (e.start <= dtend))
      # make inactive if emission has been modified
      if (e.modified? and (e.start >= dtstart) and (e.start <= dtend)) then
        e.inactivate!
        self.inactive_emissions << e
      end
    end
  end

end
