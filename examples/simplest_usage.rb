require 'rubygems'
require 'tagged_logger'
require 'logger'

puts "\n<<<#{File.basename(__FILE__, ".rb")}>>> \n".upcase

TaggedLogger.rules do
  info /.*/, :to => Logger.new(STDOUT)
end

class A
  def foo
    logger.warn "WARNING message" #will be printed since treshold is set to 'info'
  end
  logger.debug "DEBUG message" #will not be printed since we have only 'info' rule
end

logger.info("INFO message") #will be printed
A.new.foo
