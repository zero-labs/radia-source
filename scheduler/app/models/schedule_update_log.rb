
class ScheduleUpdateLog < Kernel::OperationLog
  validates_inclusion_of :status, :in  => [:initialized, :downloading, :parsing, :processing, :saving, :completed, :failed]
end
