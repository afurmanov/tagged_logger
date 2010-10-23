require File.join(File.dirname(__FILE__), '/examples_helper')

puts "\n<<<#{File.basename(__FILE__, ".rb")}>>> \n".upcase

class LogFoo
  def foo
    logger.info("#{self.class}#foo")
  end
end

Ftp = Class.new LogFoo
Http = Class.new LogFoo
Sockets = Class.new LogFoo

TaggedLogger.rules do
  format { |level, tag, message| "#{tag}: #{message}\n"}
  puts "- Only logging from within classes Ftp, Http and Sockets will be shown in output (no LogFoo)"
  puts "  tag is also printed and it is 'Network' after renaming took place:"
  rename [Ftp, Http, Sockets] => :Network
  info :Network, :to => Logger.new(STDOUT)
end

[Ftp, Http, Sockets, LogFoo].each { |c| c.new.foo }

