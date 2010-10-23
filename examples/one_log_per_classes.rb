require File.join(File.dirname(__FILE__), '/examples_helper')

puts "\n<<<#{File.basename(__FILE__, ".rb")}>>> \n".upcase

class LogFoo
  def foo
    logger.info("#{self.class}#foo")
  end
end

module Network
  Ftp = Class.new LogFoo
  Http = Class.new LogFoo
  Sockets = Class.new LogFoo
end
include Network

def run
  [Network::Ftp, Network::Http, Network::Sockets, LogFoo].each { |c| c.new.foo }
end

TaggedLogger.rules do
  stdout = Logger.new(STDOUT)
  puts "- Only logging from within classes Ftp, Http and Sockets will be shown in output (no LogFoo):"
  info [Ftp, Http, Sockets], :to => stdout
  run
  puts "\n- Same result, but regex syntax:"
  info /(Ftp|Http|Sockets)/, :to => stdout
  run
  puts "\n- Or even shorter:"
  info /Network::/, :to => stdout
  run
end 


