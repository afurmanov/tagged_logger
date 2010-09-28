require 'rubygems'
require 'tagged_logger'
require 'logger'

puts "\n<<<#{File.basename(__FILE__, ".rb")}>>> \n".upcase

TaggedLogger.rules do
  format { |level, tag, msg| "#{level}-#{tag}: #{msg}\n"}
  info /.*/, :to => Logger.new(STDOUT)
end

logger.info("message")
