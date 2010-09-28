require 'rubygems'
require 'tagged_logger'
require 'logger'

puts "\n<<<#{File.basename(__FILE__, ".rb")}>>> \n".upcase

class Some
  def foo
    logger.info("Some information")
  end
end


TaggedLogger.rules do
  format { |level, tag, message| "#{tag}: #{message}\n"}
  puts "- Only logging for Some class is shown in STDOUT"
  puts "- Run this script again by adding '2>/dev/null' and see the difference:"
  info /.*/, :to => Logger.new(STDERR)
  info Some, :to => Logger.new(STDOUT)
end

Some.new.foo
logger.info "INFO"
