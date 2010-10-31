require 'test_helper'
require 'capybara/rails'

class LogOutput < DelegateClass(String)
  def debug(msg); self << msg;  end
  def info(msg);  self << msg;  end
  def warn(msg);  self << msg;  end
  def error(msg); self << msg;  end
  def fatal(msg); self << msg;  end
end

class LoggingTest < ActionDispatch::IntegrationTest
  include Capybara

  setup do
    @log_output = ""
    TestLogger.reset(LogOutput.new(@log_output))
  end
  
  test "the truth" do
    visit '/users'
    puts @log_output
  end
end
