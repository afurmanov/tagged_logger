require 'test_helper'
require 'capybara/rails'

class LogOutput < DelegateClass(Array)
  def debug(msg); self << msg;  end
  def info(msg);  self << msg;  end
  def warn(msg);  self << msg;  end
  def error(msg); self << msg;  end
  def fatal(msg); self << msg;  end
  
  def debug?; true; end
  def info?;  true; end
  def warn?;  true; end
  def error?; true; end
  def fatal?; true; end
end

class LoggingTest < ActionDispatch::IntegrationTest
  include Capybara

  setup do
    @output = []
    TestLogger.reset(LogOutput.new(@output))
  end
  
  test "logging in Rails is redirected by TaggedLogger to @output and contains expeced entries" do
    visit '/users'
    output = @output.join
    assert_match /UsersController\#index/, output
    assert_match /GET.+\/users/, output
  end

  def clean(out)
    result = []
    out.each do |line|
      next if line.strip.empty?
      line.gsub! /^.*>>> /, ''
      line.gsub! /[\d\.]+ms/, '' 
      line.gsub! /at (.+)/, ''
      line.gsub! /^Date:.*/, ''
      line.gsub! /Message-ID:.*@/, ''
    end
  end
  
  test "logs are same with and without TaggedLogger" do
    visit '/users'
    puts "Captured output:"
    puts @output.join("\n")
    
    second_run_out = []
    TestLogger.reset(LogOutput.new(second_run_out))
    TaggedLogger.reset
    ActionController::Base.logger = TestLogger.instance
    ActionMailer::Base.logger = TestLogger.instance
    ActiveRecord::Base.logger = TestLogger.instance
    visit '/users'
    
    second_run_out = clean(second_run_out)
    first_run_out = clean(@output)
    assert_equal first_run_out, second_run_out
  end
  
end
