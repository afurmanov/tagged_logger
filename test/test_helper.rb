lib_dir = File.dirname(__FILE__) + '/../lib'
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include? lib_dir

require 'rubygems'
require "#{lib_dir}/tagged_logger"
require "#{lib_dir}/../test/test_log_device"
require 'logger'
require 'test/unit'
require 'shoulda'
require 'rr'

