require File.join(File.dirname(__FILE__),'test_helper')

NS = RadiaSource::LightWeight


class ProgramScheduleTest < ActiveSupport::TestCase
  fixtures :all

  def setup
    #for this test the time reference is UTC 2010-12-11 12:00
    set_time_reference(Time.mktime(2010, 12, 11, 12, 00), delta=0.minutes)

    @ps = NS::ProgramSchedule.instance
    @ps.load_persistent_objects @time_reference
  end

  def test_move_to_limbo
    b = NS::Broadcast.new_from_persistent_object(
      Kernel::Broadcast.create!(:program_schedule=>Kernel::ProgramSchedule.active_instance,
                                :dtstart => @time_reference + 1.day, :dtend => @time_reference + 2.day)
    )

    # ATENTION. the ids 1 and 2 are conventions: there isn't any code that
    # enforces these ids. Maybe we should make some constants (TODO).

    assert_not_nil b.po
    assert_equal 1, b.po.program_schedule.id
    assert NS::ProgramSchedule.move_to_limbo(b)
    assert_equal 2, b.po.program_schedule.id

  end

  def test_load_persistent_objects

    assert_equal Kernel::Broadcast.find_greater_than(@time_reference, :active=>true).count,
      @ps.broadcasts.count
    assert_equal Kernel::Broadcast.find_greater_than(@time_reference, :active=>false).count,
      @ps.instance_variable_get(:@inactive_broadcasts).count
    #assert_equal Kernel::Conflict.count, @ps.conflicts.count

    assert_equal Kernel::Original.find_greater_than(@time_reference, :active=>true).count,
      @ps.broadcasts.find_all{|x| x.kind_of?(NS::Original)}.count
    #assert_equal Kernel::Repetition.find(:all, :conditions => {:active => true}).count,
    assert_equal Kernel::Repetition.find_greater_than(@time_reference, :active=>true).count,
      @ps.broadcasts.find_all{|x| x.kind_of?(NS::Repetition)}.count
    
  end
  
  def test_prepare_update
    @ps.prepare_update

    assert_equal Broadcast.find_greater_than(@time_reference, :active=>true).select{|x| not x.dirty?}.count, @ps.to_destroy.count
    assert_equal Broadcast.find_greater_than(@time_reference, :active=>true).select{|x| x.dirty?}.count, @ps.to_move.count
    assert_equal 0, @ps.broadcasts.count

  end

  def test_parse_calendars1
    @ps.prepare_update
    rt = @ps.parse_calendars(get_calendars(1), @time_reference+2.months, @time_reference) 

    assert_equal 0, rt[:ignored_programs].count

    assert rt.has_key?(:originals)
    assert rt.has_key?(:repetitions)
    
    assert_equal 4, rt[:originals].count
    assert_equal 4, rt[:originals].select{|x| x.structure_template.name == 'Recorded' }.count

    assert_equal 4, rt[:repetitions].count
    assert_equal 0, rt[:ignored_repetitions].count
  end


  def test_parse_calendars2
    @ps.prepare_update
    rt = @ps.parse_calendars(get_calendars(2), @time_reference+2.months, @time_reference) 

    assert_equal 0, rt[:ignored_programs].count

    assert rt.has_key?(:originals)
    assert rt.has_key?(:repetitions)

    n = rt[:originals].count
    assert n == 20 or n == 18

    if n == 20
      Kernel.warn "warning: your Radia Source doesn't support EXDATE ical property"
      assert_equal 16, rt[:originals].select{|x| x.structure_template.name == 'Live' }.count
    else
      assert_equal 14, rt[:originals].select{|x| x.structure_template.name == 'Live' }.count
    end

    assert_equal  4, rt[:originals].select{|x| x.structure_template.name == 'Recorded' }.count


    assert_equal 4, rt[:repetitions].count
    assert_equal 0, rt[:ignored_repetitions].count
  end

  def test_add_broadcasts_cal3
    @ps.prepare_update
    rt = @ps.parse_calendars(get_calendars(3), @time_reference+2.months, @time_reference) 

    assert_equal CAL3_TOTAL_ORIGINALS, rt[:originals].count
    assert_equal CAL3_TOTAL_REPETITIONS, rt[:repetitions].count
    

    assert_difference '@ps.broadcasts.count', CAL3_TOTAL_ORIGINALS+CAL3_TOTAL_REPETITIONS do
      rt[:originals].each{|bc| @ps.add_broadcast! bc}
      rt[:repetitions].each{|bc| @ps.add_broadcast! bc}
    end

    assert_equal CAL3_TOTAL_ORIGINALS+CAL3_TOTAL_REPETITIONS-1, @ps.instance_variable_get(:@timeframes).count

  end

  def test_save_cal1
    rt = @ps.parse_calendars(get_calendars(1), @time_reference+2.months, @time_reference) 

    tmp = Broadcast.find :all, :conditions => {:program_schedule_id => 1, :active => true}

    old_broadcasts_count = tmp.count
    limbo_broadcasts_count = Broadcast.find(:all, :conditions => {:program_schedule_id => 2}).count
    dirty_broadcasts_count = tmp.select {|x| x.dirty?}.count


    assert_difference '@ps.broadcasts.count', CAL1_TOTAL_ORIGINALS+CAL1_TOTAL_REPETITIONS do
      rt[:originals].each{|bc| @ps.add_broadcast! bc}
      rt[:repetitions].each{|bc| @ps.add_broadcast! bc}
    end

    @ps.save

    assert_equal 0, Kernel::Conflict.count
    assert_equal 0, (Kernel::Broadcast.all :conditions => {:program_schedule_id => 1, :active => false}).count

    assert_equal limbo_broadcasts_count+dirty_broadcasts_count, (Broadcast.all  :conditions=>{:program_schedule_id=>2}).count
    assert_equal CAL1_TOTAL_ORIGINALS+CAL1_TOTAL_REPETITIONS, (Broadcast.all :conditions=>{:program_schedule_id=>1, :active=>true}).count



  end


  protected
  def set_time_reference(t=nil, delta=5.minutes)
    if t.nil?
      earlier = Broadcast.all.min {|x,y| x.dtstart <=> x.dtstart }

      if earlier.nil?
        @time_reference = Time.now - delta
      else
        @time_reference = earlier.dtstart - delta
      end
    else
      @time_reference = t - delta
    end
  end

  #### def get_active_broadcasts
  ####   cfs = Kernel::Conflict.all

  ####   # all conflicting active broadcasts 
  ####   a_bcs = cfs.map{|x| x.active_broadcast}.select{|x| !x.nil?}

  ####   # all non conflicting active broadcasts
  ####   na_bcs= Kernel::Broadcast.all.select{|x| ! a_bcs.include?(x) }
  ####   return a_bcs, na_bcs
  #### end

  def get_calendars n
    require 'vpim'
    require 'radia_source/ical'
    path_base = (File.expand_path File.dirname(__FILE__)) + (File.join %W(#{File::SEPARATOR}.. .. calendars lightweight #{File::SEPARATOR}))

    #ics = %x(ls #{path_base}/*ics).split

    calendars = {:originals => {}}
    %w(Recorded Live Playlist).each do |kind|
      filename = path_base + kind.downcase + "_#{n}.ics"

      if File.exist? filename
        calendars[:originals][kind] =  Vpim::Icalendar.decode(File.open filename)
      end
    end

    #recorded = Vpim::Icalendar.decode File.open(path_base + "recorded_#{n}.ics")

    filename = path_base + "repetitions_#{n}.ics"
    rep = Vpim::Icalendar.decode(File.open filename)

    return calendars.update( {:repetitions => rep})
  end

end
