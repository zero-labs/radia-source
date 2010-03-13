class ProgramSchedule < ActiveRecord::Base
  include ActiveRecord::Singleton # Forces single record for this model
  extend RadiaSource::TimeUtils

  has_many :broadcasts, :order => 'dtstart ASC'
  has_many :originals, :order => 'dtstart ASC'
  has_many :repetitions, :order => 'dtstart ASC'
  has_many :programs, :through => :originals
    
  # Expects a Hash with the following key-value pairs:
  # * :calendar => iCalendar file
  # * :start => { :year => <start year>, :month => <start month>, :day => <start day>, :hour => <start hour>, :day => <start day> } 
  # * :end => { :year => <end year>, :month => <end month>, :day => <end day>, :hour => <end hour>, :day => <end day> } 
  # * :originals => "1" or "0"
  # * :type => StructureTemplate id (or 0 for repetitions)
  # 
  # Returns an Array with 3 elements (also Arrays): 
  # * :to_create => Broadcasts to be created
  # * :to_destroy => Broadcasts to be destroyed
  # * :ignored => Programs ignored because they don't exist in the DB
  # * :conflicting => Broadcasts currently in the DB that conflict with those that are to be created
  #
  # If the iCalendar attribute is nil or empty (no events), the method returns nil
  def load_calendar(params)
    dtstart = (params[:start] ? ProgramSchedule.get_datetime(params[:start]) : Time.now)
    dtend = ProgramSchedule.get_datetime(params[:end])
    type = (params[:repeat].to_i == 1 ? 0 : params[:type])
    parse_calendar(params[:calendar], type, dtstart, dtend)
  end
  
  # Expects a Hash of Hashes containing the attributes to create new originals
  # Each entry is of the following form:
  # {<sequence_number> => { :program => <program_id>, :start => <date str>, :end => <date str>, :type => <type_id> }
  # 
  # Returns an Array with all the originals that were not created
  def update_originals(to_create, to_destroy)
    to_destroy.each_key { |b| Broadcast.find(b).destroy } unless to_destroy.nil? or to_destroy.empty?
    problems = to_create.select { |id, broadcast| !create_broadcast(broadcast) } unless to_create.nil?
    return true if to_destroy.nil? and to_create.nil?
    problems
  end
  
  # Receives a String and finds originals of that type.
  # Returns an Array with the requested originals.
  def originals_by_type(type)
    structure_template = StructureTemplate.find_by_name(type)
    return [] if structure_template.nil?
    
    self.originals.find(:all, :conditions => ["structure_template_id = ?", structure_template.id])
  end
  
  def broadcasts_and_gaps(dtstart, dtend)
    (self.broadcasts.find_in_range(dtstart, dtend) + Gap.find_all(dtstart, dtend)).sort
  end

  def content_for_gap(length)
    assets = AudioAsset.find(:all, :conditions => ["available = ?", true])
    res = assets.select { |a| (a.length - length).abs < 60 }
    res.empty? ? Playlist.find(:first) : res.first
  end
  
  def now_playing
    t = Time.now
    broadcasts.find(:first, :conditions => ["dtstart <= ? AND dtend >= ?", t, t], :order => 'dtstart ASC') || Gap.new
  end
  
  def to_xml(options = {})
    options[:indent] ||= 2
    options[:dtstart] ||= Time.now
    options[:dtend] ||= 1.day.from_now
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    bcs = self.broadcasts_and_gaps(options[:dtstart], options[:dtend])
    xml.schedule do
      bcs.to_xml(:root => 'broadcasts', :skip_instruct => true, :builder => xml)
    end
  end
  
  
  protected
  
  def parse_calendar(icalendar, type, dtstart, dtend)
    return nil if icalendar.nil? or icalendar.blank? or type.blank?
    calendars = Vpim::Icalendar.decode(icalendar)
    return nil if calendars.blank?
    
    to_create = []; to_destroy = []; ignored = []; conflicting = []
    
    calendars.each do |cal|
      cal.events do |event|
        
        if !(program = Program.find_by_name(event.summary))
          ignored << event.summary
          next
        end
        
        event.occurrences(dtend) do |occurrence|
          next if occurrence < dtstart

          check = check_event(type, program, occurrence, occurrence + event.duration)
          next if check.nil? # there's nothing to create, destroy or conflict! :)
          e = original_hash(type, program, occurrence, occurrence + event.duration)
          to_create << e unless e.nil?
          to_destroy += check[0]
          conflicting += check[1]
        end
      end
    end
    # Note: Conflicts between new broadcasts are only checked when they're actually created
    { :to_create => to_create, :to_destroy => to_destroy, :ignored => ignored, :conflicting => conflicting }
  end
  
  def check_event(type, program, dtstart, dtend)
    conflicting = []; to_destroy = [];
    bcs = self.broadcasts.find_in_range(dtstart, dtend)
    
    # If there is only one broadcast at the same time, and it is from the same program, all is good!
    if (bcs.size == 1) and (bcs.first.program == program) and bcs.first.same_time?(dtstart, dtend)
      return nil
    end
    
    bcs.each do |b|
      if b.modified? 
        conflicting << { :program => program, :dtstart => dtstart.to_s, :dtend => dtend.to_s, :type => b.structure_template, :broadcast => b }
      elsif !b.same_time?(dtstart, dtend) or (b.program != program)                              
        to_destroy  << { :program => program, :dtstart => dtstart.to_s, :dtend => dtend.to_s, :type => b.structure_template, :broadcast => b }
      end
    end
    [to_destroy, conflicting]
  end
  
  def original_hash(type, program, dtstart, dtend)
    hsh = { :type => type, :program => program, :dtstart => dtstart.to_s, :dtend => dtend.to_s }
    if type == 0 # repetition
      if e = program.find_first_original_before_date(dtstart)
        hsh.merge!(:original => e)
      else # there may not be originals to be found
        return nil
      end
    end
    hsh
  end
  
  def create_broadcast(broadcast)    
    if broadcast[:type].to_i != 0
      create_original(broadcast)
    else
      create_repetition(broadcast)
    end
  end
  
  def create_original(original)
    e = Original.new(:program_schedule => self,
                    :program => Program.find(original[:program]),
                    :structure_template => StructureTemplate.find(original[:type]),
                    :dtstart => DateTime.parse(original[:dtstart]),
                    :dtend => DateTime.parse(original[:dtend]))
    e.save
  end
  
  def create_repetition(repetition)
    r = Repetition.new(:program_schedule => self,
                       :original => Original.find(repetition[:original]),
                       :dtstart => DateTime.parse(repetition[:dtstart]),
                       :dtend => DateTime.parse(repetition[:dtend]))
    r.save
  end
end
