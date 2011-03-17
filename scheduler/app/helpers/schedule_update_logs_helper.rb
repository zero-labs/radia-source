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

end
