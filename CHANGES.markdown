# tagged_logger changelog

## Version 0.2.5

* If somebody is not ready to define any logging rules, but still want to use *#logger()* everywhere:

        TaggedLogger.init

* Runs about 3 times faster by executing code responsible for rule matching on the first *#logger()* call and "precompiling" it.
So rather than iterating over **all** rules on every _#logger_ call only subset of rules specific to *#logger()* callee get executed.

* Code simplified
   
## Version 0.3.0

* The DSL for defining rules is changed - instead of

        output /A/ => ...

    use one of:
  
        debug /A/, :to => ...
        info  /A/, :to => ...
        warn  /A/, :to => ...
        error /A/, :to => ...
        fatal /A/, :to => ...

    and instead of 

        output /A/ do
          #...
        end
    
    use 

        debug /A/ do #or #info, #warn, #error, #fatal
          #...
        end  


    These rules are more specific since they name logging level explictly which makes DSL shorter, 
    also such form has allowed to make some optimization.

* The *#format()* could be used inside *rules* block:

        TaggedLogger.rules do
          format { |level, tag, msg| "#{level}-#{tag}: #{msg}\n"}
          info /.*/, :to => Logger.new(STDOUT)
        end
