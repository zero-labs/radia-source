
require 'yaml'

module RadiaSource
  module LightWeight

    class ImportException < Exception

      def initialize msg=nil
        msg ||= 'general import error'
        super(msg)
      end
      
      def to_operation_log_msg
        self.message
      end

    end

    class CalendarFetchFailedException < ImportException
      
      def initialize(calendars, msg=nil)
        super(msg)
        @calendars = calendars
      end

      def to_operation_log_msg
        @calendars.to_yaml
      end
    end

    class UnknownProgramException < ImportException
      def initialize(programs,msg=nil)
        super(msg)
        @unknown_programs = programs
      end

      def to_operation_log_msg
        @unknown_programs.to_yaml
      end
    end

    class MissingBroadcastTypes < ImportException
    end

    class ScheduleSaveException < ImportException
    end
  end
end
