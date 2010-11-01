require 'test_helper'
require 'capybara/rails'

class LogOutput < DelegateClass(Array)
  def debug(msg); self << msg;  end
  def info(msg);  self << msg;  end
  def warn(msg);  self << msg;  end
  def error(msg); self << msg;  end
  def fatal(msg); self << msg;  end
end

class LoggingTest < ActionDispatch::IntegrationTest
  include Capybara

  setup do
    @log_output = []
    TestLogger.reset(LogOutput.new(@log_output))
  end
  
  test "logging output" do
    visit '/users'
    puts "----original captured output-----------------"
    puts @log_output.join("\n")
    puts "---------------------------------------------"
    output = @log_output.join
    assert_match /UsersController\#index/, output
    assert_match /GET.+\/users/, output
  end
end
