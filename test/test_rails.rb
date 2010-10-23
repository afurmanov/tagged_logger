require File.join(File.dirname(__FILE__), '/test_helper')
require 'rails/all'

module Test
  def self.rails_log_device
    @rails_log_device ||= TestLogDevice.new
  end
  
  class Application < Rails::Application
    config.logger = Logger.new(Test.rails_log_device)
  end
end

class TestController < ActionController::Base
  def hi
    logger.info "hi"
  end
end

Test::Application.initialize!

class TaggedLoggerRailsTest < Test::Unit::TestCase
  include RR::Adapters::TestUnit

  context "stub output device @@stub_out;" do
    setup do
      @@stub_out = TestLogDevice.new
    end
    
    teardown do
      TaggedLogger.restore_old_logger_methods
    end

    should "be able possible to initialize in the way to override Rails existing logger" do
      assert TestController.new.respond_to? :logger
      TaggedLogger.rules(:override=>true) do 
        info /.*/ do |level, tag, message|
          @@stub_out.write(tag.to_s)
        end
      end
      @@stub_out.write("TestController")
      TestController.new.hi
    end
    
    should "be possible to restore old logger methods" do
      TaggedLogger.rules(:override=>true) do 
        info(/.*/) {|level, tag, message|}
      end
      TaggedLogger.restore_old_logger_methods
      mock(Test.rails_log_device).write("hi\n")
      TestController.new.hi
    end
    
  end    
end

