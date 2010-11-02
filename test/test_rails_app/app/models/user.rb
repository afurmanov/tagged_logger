class User < ActiveRecord::Base
  def self.everyone
    logger.debug "everyone..."
    all
  end
end
