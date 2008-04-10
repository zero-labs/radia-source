class ProgramSchedule < ActiveRecord::Base
  include ActiveRecord::Singleton # Forces single record for this model
  include TimeUtils

  has_many :emissions, :order => 'start ASC'
  has_many :programs, :through => :emissions
  
  has_many :recorded_emissions, :order => 'start ASC', :conditions => ["active = ?", true]
  has_many :live_emissions, :order => 'start ASC', :conditions => ["active = ?", true]
  has_many :playlist_emissions, :order => 'start ASC', :conditions => ["active = ?", true]
  has_many :repeated_emissions, :order => 'start ASC', :conditions => ["active = ?", true]
  
  has_many :inactive_emissions, :order => 'start ASC', :class_name => 'Emission', :conditions => ["active = ?", false]

  acts_as_emission_process_configurable :recorded => true

  def update_emissions(params)
    dtstart = (params[:start] ? TimeUtils.get_datetime(params[:start]) : Time.now)
    dtend = TimeUtils.get_datetime(params[:end])
    ignored = []
    
    params[:calendars].each_key do |key|
      next if params[:calendars][key].blank? or key.to_sym == :repeated
      ignored << update_by_type(key.to_sym, params[:calendars][key], dtstart, dtend)
    end
    
    if params[:calendars][:repeated] then
      ignored << update_by_type(:repeated, params[:calendars][:repeated], dtstart, dtend)
    end
    
    move_repetitions unless params[:calendars][:repeated]
    
    purge_emissions
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
    
    flag_emissions(type, dtstart, dtend)
    ignored = []
    
    calendars.each do |cal|
      cal.components(Vpim::Icalendar::Vevent) do |event|
        # TODO create recurrence object
        program = Program.find_by_name(event.summary)
        if program
          event.occurences.each(dtend) do |occurrence|
            if occurrence >= dtstart then
              if type == :repeated
                deal_with_repetition(program, event, occurrence)
              else
                deal_with_occurrence(type, program, event, occurrence)
              end
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
    return if emissions.nil?
    
    emissions.each do |e|
      if (e.start == occurrence) and (e.end == (occurrence + event.duration)) then
        e.unflag!
        return
      end
    end
    # if it got here it's because the emission is different from existing ones
    create_emission(type, program, occurrence, occurrence + event.duration)
  end
  
  def deal_with_repetition(program, event, occurrence)
    emission = program.find_first_emission_before_date(occurrence)
    return if emission.nil?    
    create_emission(:repeated, program, occurrence, occurrence + event.duration, emission)
  end
  
  # Emission type, start and end date/time
  def create_emission(type, program, dtstart, dtend, emission = nil)
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
    when :repeated
      e = RepeatedEmission.new(:start => dtstart, :end => dtend, 
                              :program => program, :program_schedule => self, :emission => emission)
      self.repeated_emissions << e
    end
    
    (e.save ? e : nil)
  end
  
  # Flags emissions within the given timeframe
  # Destroys unaltered emissions and inactivates those with changes
  def flag_emissions(type, dtstart, dtend)
    case type
    when :recorded
      k = self.recorded_emissions.find(:all, :conditions => ["start BETWEEN ? AND ?", dtstart, dtend])
    when :live
      k = self.live_emissions.find(:all, :conditions => ["start BETWEEN ? AND ?", dtstart, dtend])
    when :playlist
      k = self.playlist_emissions.find(:all, :conditions => ["start BETWEEN ? AND ?", dtstart, dtend])
    when :repeated
      k = self.repeated_emissions.find(:all, :conditions => ["start BETWEEN ? AND ?", dtstart, dtend])
    end
    
    k.each { |e| e.flag! }
  end
  
  def move_repetitions
    
  end
  
  # Destroys unmodified flagged emissions
  # Inactivates modified flagged emissions
  def purge_emissions
    emissions = Emission.find(:all, :conditions => ["flag = ?", true])
    emissions.each do |e|  
      e.destroy if !e.modified?
      if e.modified? then
        e.inactivate!
        self.inactive_emissions << e
      end
    end
  end
end
