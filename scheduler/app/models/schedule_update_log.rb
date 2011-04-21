class ScheduleUpdateLog < OperationLog
  symbolize :status, :in  => [:initialized, :downloading, :parsing, :processing, :persisting, :completed, :failed]
end
