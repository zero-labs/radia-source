class Gap < Broadcast

  def gap?
    true
  end

  def self.find_all(date_start, date_end)
    return [] if date_start >= date_end
    query =  "SELECT A.dtend as dtstart, B.dtstart as dtend "
    query << "FROM broadcasts A, broadcasts B "
    query << "WHERE A.program_schedule_id = B.program_schedule_id AND "
    query << "A.dtstart <> B.dtstart AND A.dtend <> B.dtend AND A.dtend < B.dtstart AND "
    query << "B.dtstart = (SELECT min(c.dtstart) FROM broadcasts c WHERE c.dtstart > a.dtstart) AND "
    query << "A.dtend >= ? AND B.dtstart <= ?"
    query << "order by dtstart"

    all_gaps(date_start, date_end, find_by_sql([query, date_start, date_end]))
  end

  def bloc
    b = Bloc.new
    el = BlocElement.new(:audio_asset => AudioAsset.fill(self.length))
    b.elements << el
    b
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.broadcast(:type => 'gap') do
      xml.tag!(:dtstart, self.dtstart, :type => :datetime)
      xml.tag!(:dtend, self.dtend, :type => :datetime)
      xml.tag!(:description, 'Gap', :type => :string)
      bloc.to_xml(:skip_instruct => true, :builder => xml)
    end
  end

  protected

  def self.all_gaps(dtstart, dtend, in_between)
    gaps = Array.new(in_between)
    if in_between.empty?
      if (broadcasts = Broadcast.find_in_range(dtstart, dtend)).empty?
        gaps << Gap.new(:dtstart => dtstart, :dtend => dtend) 
      else
        unless dtstart >= broadcasts.first.dtstart
          gaps << Gap.new(:dtstart => dtstart, :dtend => broadcasts.first.dtstart) 
        end
        unless broadcasts.last.dtend >= dtend 
          gaps << Gap.new(:dtstart => broadcasts.last.dtend, :dtend => dtend) 
        end
      end
    else
      if in_between.first.dtstart > dtstart
        before = Broadcast.find_in_range(dtstart, in_between.first.dtstart) 
        unless dtstart >= before.first.dtstart
          gaps.insert(0, Gap.new(:dtstart => dtstart, :dtend => before.first.dtstart)) 
        end
      end
      if in_between.last.dtend < dtend
        after = Broadcast.find_in_range(in_between.last.dtend, dtend)
        start_at = (after.empty? ? in_between.last.dtend : after.first.dtend)
        unless start_at >= dtend
          gaps.insert(-1, Gap.new(:dtstart => start_at, :dtend => dtend))
        end
      end
    end
    gaps
  end

end
