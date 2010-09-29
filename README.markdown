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


## License
*TaggedLogger* is released under the MIT license.

## Shortcomings
The *#info(), #debug(), #warn(), #error(), #fatal()* rules when having form like *:to => logger*, the 
*logger* **has** to be an object of standard library *Logger* class. If you need to use different sort of logger
the more general rules form is:

    TaggedLogger.rules do
      info /Whatever/ do |level, tag, message|
        #do your special logging here
      end      
    end
