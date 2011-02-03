require 'test_helper'

NS = RadiaSource::LightWeight


class ProgramSchedule < ActiveSupport::TestCase
  fixtures :all

  def setup
    
    #for this test the time reference is UTC 2010-12-11 12:00
    set_time_reference(Time.mktime(2010, 12, 11, 12, 00), delta=0.minutes)

    @ps = NS::ProgramSchedule.instance
    @ps.load_persistent_objects @time_reference
  end

  def test_load_persistent_objects

    assert_equal Kernel::Broadcast.count,
      @ps.broadcasts.count
    assert_equal Kernel::Conflict.count, @ps.conflicts.count

    assert_equal Kernel::Original.count,
      @ps.broadcasts.find_all{|x| x.kind_of?(NS::Original)}.count
    assert_equal Kernel::Repetition.count,
      @ps.broadcasts.find_all{|x| x.kind_of?(NS::Repetition)}.count
    
  end


  def test_find_or_create_conflict_by_active_broadcast
    assert @ps.find_or_create_conflict_by_active_broadcast broadcasts(:original1)
    assert @ps.find_or_create_conflict_by_active_broadcast broadcasts(:original2)
  end

  def test_add_conflict

    a_bcs, na_bcs = get_active_broadcasts

    assert_no_difference '@ps.conflicts.count' do
      @ps.add_conflict:conflict => (@ps.find_or_create_conflict_by_active_broadcast a_bcs[0])
    end

    assert_difference '@ps.conflicts.count' do
      @ps.add_conflict:conflict => (@ps.find_or_create_conflict_by_active_broadcast na_bcs[0])
    end
  end
  
  def test_add_broadcast
  end


  def test_prepare_update
    @ps.prepare_update

    assert_equal Broadcast.count, @ps.to_destroy.count
    assert_equal Conflict.count, @ps.conflicts.count
  end

  def test_parse_calendars1
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
    rt = @ps.parse_calendars(get_calendars(3), @time_reference+2.months, @time_reference) 

    assert_equal CAL3_TOTAL_ORIGINALS, rt[:originals].count
    assert_equal CAL3_TOTAL_REPETITIONS, rt[:repetitions].count
    nconflicts = @ps.conflicts.count


    assert_difference '@ps.broadcasts.count', CAL3_TOTAL_ORIGINALS+CAL3_TOTAL_REPETITIONS do
      rt[:originals].each{|bc| @ps.add_broadcast bc}
      rt[:repetitions].each{|bc| @ps.add_broadcast bc}
    end

    assert_equal nconflicts+CAL3_TOTAL_ORIGINALS+CAL3_TOTAL_REPETITIONS-1, @ps.conflicts.count

    tmp =@ps.conflicts.find_all {|x| x.new_broadcasts.count > 1 }
    assert_equal 1, tmp.count
    assert_equal Time.mktime(2010,12,31,15,00),  tmp.first.new_broadcasts.first.dtstart 

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

  def get_active_broadcasts
    cfs = Kernel::Conflict.all

    # all conflicting active broadcasts 
    a_bcs = cfs.map{|x| x.active_broadcast}.select{|x| !x.nil?}

    # all non conflicting active broadcasts
    na_bcs= Kernel::Broadcast.all.select{|x| ! a_bcs.include?(x) }
    return a_bcs, na_bcs
  end

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
