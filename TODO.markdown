### ActiveResource::LogSubscriber instrumentation
### Tests for Rails instrumentation
### Refactor TagMatcher#match? with ===
### Documentation

### Ability to accept blocks as arguments for #debug, #info, and alike, i.e.:

    logger.info { "That message takes some time to build' }
   
   so message is evaluated only when actual logging happens, and no-op otherwise


### Writing messages in any encoding (tests)

### Tests against 'logging' framework: http://github.com/TwP/logging

### When logger specified in :to => ... then lib must complain if it cannot find standard logger methods there (and formatting setter)

### :fsync convenience option, so instead:

    log = open(File.join(log_path, 'log.log'),"w")
    debug GData::Cacher, :to => Logger.new(log) do
      log.fsync
    end

one could write:

    debug GData::Cacher, :to => Logger.new('log.log'), :fsync => true

### Non-intrusive instrumentation, for example:

    instrument "SomeClass#method", :debug
 
which in turn wraps *SomeClass#method* with before call:

    logger.debug("SomeClass#method/started [timestamp]")

and after call:

    logger.debug("SomeClass#method/stopped [timestamp]")

so instrumentation is defined just as a special case for logging and 
it is regulated by same rules mechanism, i.e. it could be turned on by rule: 

    debugger SomeClass do |level, info, msg| do
    end

sometimes we want to know an average information across many method call, so may be:

    instrument "SomeClass#method", :debug, :average_for => 100
                            
It is needed for better profiling
