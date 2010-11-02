if Rails.env == "test"

  require 'test_logger'
  
  TaggedLogger.rules do
    debug /.*(\.logsubscriber|Controller|User)$/ do |level, tag, msg|
      TestLogger.instance.send(level, "#{tag}>>> #{msg}")
    end
  end
  
end
