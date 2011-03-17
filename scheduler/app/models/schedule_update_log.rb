class ScheduleUpdateLog < OperationLog
  validates_inclusion_of :status, :in  => [:initializing, :downloading, :parsing, :processing, :persisting, :completed, :failed]
end
