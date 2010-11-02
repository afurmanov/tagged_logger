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
