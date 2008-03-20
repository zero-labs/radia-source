# Testing singleton classes is a bit tricky, because you probably want to
# reset the singleton between tests.  This can't really be done without violating
# Singleton's purpose in life.  The solution is to do the following:
#   
#   Singleton.send :__init__, TheSingletonClassInQuestion # <= a class
#
# So we add this as in reset_instance method to the singleton module when we're testing
require 'singleton'

class << Singleton
  def included_with_reset(klass)
    included_without_reset(klass)
    class <<klass
      def reset_instance
        Singleton.send :__init__, self
        self
      end
    end
  end
  alias_method :included_without_reset, :included
  alias_method :included, :included_with_reset
end

module ActiveRecordSingletonSpecHelper
  def reset_singleton(klass)
    klass.reset_instance
    klass.delete_all
  end
end