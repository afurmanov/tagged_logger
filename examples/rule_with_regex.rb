require File.join(File.dirname(__FILE__), '/examples_helper')

puts "\n<<<#{File.basename(__FILE__, ".rb")}>>> \n".upcase

module Active
  class Base
    def foo
      logger.info("foo")
    end
  end
end

TaggedLogger.rules do
  puts "- The recommended way to specify logging for all classes within same namespace:"
  info /Active::/, :to => Logger.new(STDOUT)
end

Active::Base.new.foo
