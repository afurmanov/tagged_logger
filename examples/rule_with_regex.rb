require 'rubygems'
require 'tagged_logger'
require 'logger'

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
