require File.join(File.dirname(__FILE__), '/examples_helper')

puts "\n<<<#{File.basename(__FILE__, ".rb")}>>> \n".upcase

TaggedLogger.rules do
  format { |level, tag, msg| "#{level}-#{tag}: #{msg}\n"}
  info /.*/, :to => Logger.new(STDOUT)
end

logger.info("message")
