class ProgramSchedule < ActiveRecord::Base
  include ActiveRecord::Singleton # Forces single record for this model
  include TimeUtils

  has_many :emissions, :order => 'start ASC'
  has_many :programs, :through => :emissions
  
  has_many :recorded_emissions, :order => 'start ASC'
  has_many :live_emissions, :order => 'start ASC'
  has_many :playlist_emissions, :order => 'start ASC'

  def update_emissions(params)
    dtstart = TimeUtils.get_datetime(params[:start])
    dtend = TimeUtils.get_datetime(params[:end])
    params[:calendars].each_key do |key|
      update_by_type(key.to_sym, params[:calendars][key], dtstart, dtend)
    end    
    self.save
  end

  protected

  # Updates the schedule for a given type of emission
  # with events occurring between dtstart and dtend
  def update_by_type(type, icalendar, dtstart, dtend)
    return if icalendar.nil? or icalendar.blank?
    
    calendars = Vpim::Icalendar.decode(icalendar)
    return if calendars.blank? 
    
    # Destroy emissions within the given timeframe
    destroy_emissions(type, dtstart, dtend)
    
    calendars.each do |cal|
      cal.components(Vpim::Icalendar::Vevent) do |event|
        # TODO create recurrence object
        program = Program.find_by_name(event.summary)
        if program then
          event.occurences.each(dtend) do |occurrence|
            # create emission if occurrence date >= dtstart
            if occurrence >= dtstart then
              em_start = occurrence
              em_end = em_start + event.duration
              create_emission(type, program, em_start, em_end)
            end
          end
        end
      end
    end
  end
  
  # Emission type, start and end date/time
  def create_emission(type, program, dtstart, dtend)
    case type
    when :recorded
      e = RecordedEmission.new(:start => dtstart, :end => dtend, :program => program)
      self.recorded_emissions << e
    when :live
      e = LiveEmission.new(:start => dtstart, :end => dtend, :program => program)
      self.live_emissions << e
    when :playlist
      e = PlaylistEmission.new(:start => dtstart, :end => dtend, :program => program)
      self.playlist_emissions << e
    end
    self.emissions << e
    #program.emissions << e
  end
  
  def destroy_emissions(type, dtstart, dtend)
    case type
    when :recorded
      k = self.recorded_emissions
    when :live
      k = self.live_emissions
    when :playlist
      k = self.playlist_emissions
    end
    k.each { |e| e.destroy if ((e.start >= dtstart) and (e.start <= dtend)) }
  end

end
