require 'logger'
require 'delegate'

class TestLogger < DelegateClass(Logger)
  include Singleton
  def initialize
    super nil
  end
  class <<self
    def reset(output)
      instance.__setobj__(output)
    end
  end
end

TaggedLogger.rules do
  debug /.*(\.logsubscriber|Controller)$/ do |level, tag, msg|
    TestLogger.instance.send(level, msg)
  end
end

