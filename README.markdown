# TaggedLogger
Detaches **what** is logged from **how** it is logged.

## What is it for?
Every time you want to log something, simply write:

    logger.debug("verbose debug information") #warn, #info, #error, #fatal also works

and do not worry about what kind of logger you use and how your code accesses it.
You may configure these things later, one day writing to STDOUT works for you, another
day you'll need something more sophisticated, like several log files each serving 
different components and for different audience. [Here](http://afurmanov.com/2009/10/19/tagged-logger-introduction)
I have described in more details why I created it.

## Installation
    $ gem install tagged_logger

## Usage

After specifying some logging rules:
    
    TaggedLogger.rules do
      info A, :to => Logger.new("log_for_A_class.log") #1 rule
      error /.*/, :to => Logger.new(ERROR)             #2 rule
      info /.*/, :to => Logger.new(STDOUT)             #3 rule
    end

the following will happen:

1. The *#logger()* method becomes available **everywhere**, so it is completely safe to have a code like:

        class A
          def foo
             logger.info("Something interesting happened in A#foo") #goes to STDOUT and to 'log_for_A_class.log' file
             logger.debug("I want to see some details.") #goes nowhere
          end
        end
        logger.error("#logger is available everywhere") #goes to STDERR
        class B
           logger.warn("#logger is available everywhere") #goes to STDOUT
        end     

2. The A's *logger.info()* output will show up in two destinations:
 
    - in STDOUT, as defined by rule #3

    - in 'log_for_A_class.log' file, as defined by rule #1

3. From **wherever** it gets called from:

        logger.error("ERROR") #will print 'ERROR' in standard error
        logger.info("INFO")  #will print 'INFO' in standard output
        logger.debug("DEBUG") #will not print anything, since there is no 'debug' rule


The *#logger()* returns some object having methods: *#debug(), #info(), #warn(), #error() and #fatal()*. 
These methods have generated on first *#logger()* call and contain only necessary code to meet rules.
It means, for example, that if no rules defined all these methods do nothing. It is done for performance
reasons, I like to log a lot and I do not want calls like *#logger.debug()* slowing down production code.
 

The simplest way to have a *#logger()* available everywhere without specifying any rules is:

    TaggedLogger.init

No rules specified, therefore whenever you call *logger.debug()* (or alike) you actually paying for just an empty method
execution. You may specify rules later, now you may stay focused on code you are writing.


You may define your own formatting:

    TaggedLogger.rules do
      format {|level, tag, message| "#{level}-#{tag}: #{msg}"}
    end

Each *#format()* call overrides previous format.
If you are wondering what the heck the 'tag' is - the answer is simple. The tag is a class name
whose method calls *#logger()*. This is what allows to specify rules for classes or namespaces and this 
is what the *tagged_logger* plugin is named after.

Lets see how you may use it. For example you want to have separate log files 
for classes *Network* and *Database*:

    TaggedLogger.rules do
      debug Network, :to => Logger.new("network.log")
      debug Database, :to => Logger.new("database.log")
    end
   
In case you want to define common log for several classes:

    TaggedLogger.rules do
      debug [Ftp, Http, Sockets], :to => Logger.new("network.log")
    end 

Or if you want to have all these classes showing up under common 
tag *Network* in standard output:

    TaggedLogger.rules do
      info /.*/, :to => Logger.new(STDOUT)
      rename [Ftp, Http, Sockets] => :Network
    end
   
You may also use regular expressions in your rules:

    TaggedLogger.rules do
      info /Active::/, :to => Logger.new("active.log")
    end


There is more general form for rules, it accepts block with three params:

    TaggedLogger.rules do
      info /Whatever/ do |level, tag, message|
        #do your special logging here
      end      
    end

As previously explained the *tag* is a class name the *#logger* is being called from (except when you override Rails instrumentation, see below)

## Integration with Rails (only Rails 3.0 supported at the moment, not completely tested):
Rails has two facility for logging - *#logger* method injected in base classes such in ActiveRecord::Base and instrumentation. Instrumentation is somewhat which allows to issue an event upon execution of 
block, for example:

    def sendfile(path, options={})
      ActiveSupport::Notifications.instrument("sendfile.action_controller") do
        #do actual file send
      end
    end

The event *"sendfile.action_controller"* will be issued and one could subscribe to that event:

    ActiveSupport::Notifications.subscribe("sendfile.action_controller") do
      #do something, for example log an event
    end


Actually Rails subscribers - they are responsible for majority of logging in Rails.
*TaggedLogger* allows you to override how those subscribers do actual logging, for example if you want to override it for *ActionController*:

    # "#{Rails.root}/config/initializers/tagged_logger.rb"
    TaggedLogger.rules(:override=>true) do
      debug "action_controller.instrumentation" do |level, tag, msg|
        puts "#{tag} {msg}" #msg formed by ActionController::LogSubscriber goes here, tag is 'action_controller.instrumentation'
      end
    end

If you like to have a special logging not only for *ActionController*, but rather for everything logged by Rails via instrumentation mechanism, you could use a 
rule with regular expression:
   
    debug /.*\.instrumentation$/ do |level, tag, msg|
      #you special logging
    end


Since *#logger* is defined by Rails for classes you inherits from (*ActionController::Base*, *ActiveRecord::Base*), you have to initialize *TaggedLogger* with

    :override => true 

 option since by default *TaggedLogger* is trying to be safe and does not override existing *#logger* method:

    class ApplicationController < ActionController::Base
      def welcome
        logger.info "welcome..."
      end
    end
  
    # "#{Rails.root}/config/initializers/tagged_logger.rb"
    TaggedLogger.rules(:override=>true) do
      debug /.*Controller$/ do |level, tag, msg|
        puts "Here I dump whatever happens in controllers, including ApplicationController"
      end
    end



## License
*TaggedLogger* is released under the MIT license.

## Shortcomings
The *#info(), #debug(), #warn(), #error(), #fatal()* rules when having form like *:to => logger*, the 
*logger* **has** to be an object of standard library *Logger* class. 
