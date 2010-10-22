dir = File.dirname(__FILE__) 
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)
require 'tagged_logger/railtie'
require 'tagged_logger/tagged_logger'
