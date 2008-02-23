class ProgramScheduling < ActiveRecord::Base
  belongs_to :schedule_version
  belongs_to :program
end
