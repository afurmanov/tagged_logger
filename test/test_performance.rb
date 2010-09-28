require 'rubygems'
require File.dirname(__FILE__) + '/../tagged_logger'
require 'logger'

class TestLogDevice
  def write(msg); end
  def close; end  
  def clear; end
end

def measure_debug_time(a_logger, name)
  start_time = Time.now
  10_000.times { a_logger.debug("DEBUG")}
  puts "DEBUG: %s: %5.4f\n" % [name, (Time.now - start_time)]
end

std_logger = Logger.new(TestLogDevice.new)
std_logger.level = Logger::INFO

TaggedLogger.rules do
  info /.*/, :to => std_logger
end

measure_debug_time(std_logger, "Standard Logger")
measure_debug_time(logger, "Tagged Logger")
