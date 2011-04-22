module ScheduleUpdateLogsHelper

  def header_row_for_update_logs
    out = '<tr>'
    out << "<td>Status</td>"
    out << "<td>Start date</td>"
    out << "<td>End date</td>"
    out << "<td>Errors</td>"
    out << '</tr>'
  end

  def row_for_update_log(update_log)
    out = '<tr>'
    out << "<td>#{update_log.status.to_s}</td>"
    out << "<td>#{update_log.dtstart}</td>"
    out << "<td>#{update_log.dtend}</td>"
    out << "<td>#{update_log.operation_errors}</td>"
    out << '</tr>'
  end

  def log_resumed_message(update_log)
    case update_log.message
    when 'ignored_repetitions'
      return 'could not associate some repetitions'
    when /CalendarFetchFailedException/
      return 'could not download some calendars'
    when /UnknownProgramException/
      return 'some unknown program names'
    end
    return update_log.message.to_s
  end

  def format_datetime t
    begin
      return t.localtime.strftime('%d/%m/%y %H:%M')
    rescue NoMethodError => e
      return t
    end
  end

  def log_popup(update_log)
    id = update_log.id
    s = <<EOT
<a name='update_log_#{id}'>
  <div id='#{id}' title='%{title}'class='log_description dialog'>
  %{content}
  </div>
</a>
EOT
    return s % log_message(update_log)
  end

  def log_message(update_log)
    case update_log.message
    when 'ignored_repetitions'
      return ignored_repetitions(update_log)
    when /CalendarFetchFailedException/
      return calendars_fetch_failed(update_log)
    when /UnknownProgramException/
      return YAML::load(update_log.operation_errors)
    end
  end

  def ignored_repetitions(update_log)
    s =<<EOC
    <table id='tbl'>
      <thead>
        <tr>
          <th>%{program_name}</th>
          <th>%{dtstart}</th>
          <th>%{dtend}</th>
        </tr>
      </thead>
      <tbody>
EOC
    s = s % {
      :program_name => 'Program Name', :dtstart => 'Start Date',
      :dtend => 'End Date'}

    tmp = YAML::load(update_log.operation_errors)[:ignored_repetitions]
    tmp.each_with_index do |x,idx|
      row = <<EOT
        <tr class='%{oddness}'>
          <td>%{program}</td>
          <td>%{dtstart}</td>
          <td>%{dtend}</td>
        </tr>
EOT
      s += row % {:program=>x[:program], 
        :dtstart => format_datetime(x[:dtstart]),
        :dtend => format_datetime(x[:dtend]),
        :oddness => (idx % 2) == 0 ? 'even' : 'odd'
      }
    end
    s += '</tbody></table>'
    return {:title=> 'Ignored Repetitions',:content => s}
  end

  def calendars_fetch_failed(update_log)
    tmp = YAML::load(update_log.operation_errors)
    s = "<ul>"
    tmp.each { |x| s << "<li>#{x}</li>" }
    s << '</ul>'
    return {:title=>'Calendars Unreachable', :content => s}
  end
end
