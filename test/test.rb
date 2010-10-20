$LOAD_PATH.unshift File.dirname(__FILE__)
require 'test_helper'


class TaggedLoggerTest < Test::Unit::TestCase
  include RR::Adapters::TestUnit

  context "stub output device @@stub_out;" do
    setup do
      @@stub_out = TestLogDevice.new
    end
    
    teardown do
      TaggedLogger.restore_old_logger_methods
    end
    
    should "be able to intialize with minimal effort, without defining any rules" do
      TaggedLogger.init
      dont_allow(@@stub_out).write
      logger_method = RUBY_VERSION >= '1.9' ? :logger : "logger"
      assert Class.new.methods.include? logger_method
      assert_nothing_raised { Class.new.logger }
    end
    
    should "not override exsiting #logger method" do
      GlobalObject1 = Object
      GlobalObject1.instance_eval { define_method(:logger){@@stub_out}}
      class GlobalObject1
        def foo; logger.write("debug"); end
      end
      TaggedLogger.rules do
        reset
        debug(/.*/) { |level, tag, msg| debugger; @@stub_out.write("hmmm, something new") }
      end
      mock(@@stub_out).write("debug")
      Object.new.foo
    end

    should "override exsiting #logger method when intialized with :override" do
      GlobalObject2 = Object
      class GlobalObject2
        def logger; @logger ||= Logger.new('/dev/null');  end
        def foo; logger.debug("debug"); end
      end
      TaggedLogger.rules(:override => true) do
        reset
        debug(/.*/) { |level, tag, msg| @@stub_out.write(msg) }
      end
      mock(@@stub_out).write("debug")
      Object.new.foo
    end
    
    context "everything gets logged to @@stub_out;" do
      setup do 
        TaggedLogger.rules do
          reset
          format {|level, tag, msg| "#{tag}: #{msg}"}
          debug /.*/, :to => Logger.new(@@stub_out)
        end
      end
      
      should "write output for every of #debug, #info, #warn, #error, #fatal call" do
        NewClass = Class.new
        obj = NewClass.new
        TaggedLogger.rules { format { |level, tag, msg| "#{msg}" } }
        
        mock(@@stub_out).write("debug")
        obj.logger.debug("debug")
        mock(@@stub_out).write("info")
        obj.logger.info("info")
        mock(@@stub_out).write("warn")
        obj.logger.warn("warn")
        mock(@@stub_out).write("error")
        obj.logger.error("error")
        mock(@@stub_out).write("fatal")
        obj.logger.fatal("fatal")
      end

      context "class A and class B with logger.info() in their method #foo;" do
        setup do
          module Foo; def foo; logger.info("foo"); end; end
          class A;include Foo; end
          class B;include Foo; end
          @a = A.new
          @b = B.new
        end
       
        should "be possible to replace tags for A, B classes with single tag TEST making rules for A and B obsolete" do
          TaggedLogger.rules do
            rename [A,B] => :TEST
          end
          mock(@@stub_out).write("TEST: foo")
          @a.foo
          mock(@@stub_out).write("TEST: foo")
          @b.foo
        end

        should "use default tag equal to class name for class methods" do
          def A.bar
            logger.info "bar"
          end
          mock(@@stub_out).write("#{self.class}::A: bar")
          A.bar
        end
        
        
        context "@logger2 with stub output @@stub_out_aux;" do
          setup { @@stub_out_aux = TestLogDevice.new }
          
          should "be possible to add logging to @@stub_out_aux for A" do
            TaggedLogger.rules { debug A, :to => Logger.new(@@stub_out_aux) }
            mock(@@stub_out).write("#{self.class}::A: foo")
            mock(@@stub_out_aux).write("#{self.class}::A: foo")
            @a.foo
            mock(@@stub_out).write("#{self.class}::B: foo")
            dont_allow(@@stub_out_aux).write
            @b.foo
          end
          
          should "do logging in subclasses if superclass match the rules" do
            TaggedLogger.rules { debug A, :to => Logger.new(@@stub_out_aux) }
            class C < A; include Foo; end
            mock(@@stub_out_aux).write("#{self.class}::C: foo")
            C.new.foo
          end

          should "do logging in superclass if being called from subclass" do
            TaggedLogger.rules { debug A, :to => Logger.new(@@stub_out_aux) }
            class C < A; end
            mock(@@stub_out_aux).write("#{self.class}::C: foo")
            C.new.foo
          end

          should "be possible to speialize logging for tag A by providing block" do
            TaggedLogger.rules do
              debug A do |level, tag, msg| 
                @@stub_out_aux.write("#{level} #{tag} #{msg}")
              end
            end
            mock(@@stub_out_aux).write("info #{self.class}::A foo")
            mock(@@stub_out).write("#{self.class}::A: foo")
            @a.foo
          end
          
          should "be possible to provide block and logger together, and do actual writing by yielding" do
            TaggedLogger.rules do
              debug A, :to => Logger.new(@@stub_out_aux) do |level, tag, message|
                @@stub_out_aux.write "post write callback"
              end
            end
            mock(@@stub_out_aux).write("#{self.class}::A: foo")
            mock(@@stub_out_aux).write("post write callback")
            mock(@@stub_out).write("#{self.class}::A: foo")
            @a.foo
          end
          
          should "be possible to replace tags for A, B classes with single tag TEST and specialize logging for it" do
            TaggedLogger.rules do
              rename [A, B] => :TEST
              debug :TEST, :to => Logger.new(@@stub_out_aux)
            end
            mock(@@stub_out).write("TEST: foo")
            mock(@@stub_out_aux).write("TEST: foo")
            @a.foo
            mock(@@stub_out).write("TEST: foo")
            mock(@@stub_out_aux).write("TEST: foo")
            @b.foo
          end
          
          context "class A and class B with logger.debug() in their method #bar;" do
            setup do
              module Bar; def bar; logger.debug("bar");  end; end
              class A;include Bar; end
              class B;include Bar; end
            end
            
            should "not print debug messages if info level specified" do
              TaggedLogger.rules do
                info /A/, :to => Logger.new(@@stub_out_aux)
              end
              dont_allow(@@stub_out_aux).write
              @a.bar
            end
          end
        end
        
      end
    end
  end
  
end

