class TestLogDevice
  attr_reader :last
  def write(msg); @last = msg; end
  def close; end;  
  def to_s; @last || ""; end
  def inspect; to_s; end
  def clear; write(""); end
end
