require File.join(File.dirname(__FILE__), '/test_helper')

class DummyTestLogDevice
  def write(msg); end
  def close; end  
  def clear; end
end

def measure_debug_time(a_logger, name)
  start_time = Time.now
  10_000.times { a_logger.debug("DEBUG")}
  diff = Time.now - start_time
  puts "Performance(10,000 logger.debug calls) for %s: %5.4f sec\n" % [name, diff]
  diff
end

std_logger = Logger.new(DummyTestLogDevice.new)
std_logger.level = Logger::INFO

TaggedLogger.rules do
  info /.*/, :to => std_logger
end

std_logger_time = measure_debug_time(std_logger, "Standard Logger")
tagged_logger_time = measure_debug_time(logger, "Tagged Logger")
puts "Tagger/Standard Logger speed = %2.2f" % (tagged_logger_time/std_logger_time)
