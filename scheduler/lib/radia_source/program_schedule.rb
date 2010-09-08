module RadiaSource
  module ProgramSchedule
    module Migrate

      # conflict handling:
      #  import: old broadcasts are imported to the new schedule
      #  destroy: old broadcasts are destroyed
      #  manual: user handles the process
      #  self: on update process, a conflict was found within the new
      #        information
      def self.Actions
        return %w(import destroy manual self)
      end
      def self.DefaultAction
        return self.Actions[0]
      end
    end
  end
end
