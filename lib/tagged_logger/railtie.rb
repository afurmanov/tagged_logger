if defined?(Rails::Railtie)
  module TaggedLogger
    class Railtie < Rails::Railtie
      ActiveSupport.on_load(:action_controller) {debugger; TaggedLogger.send(:inject_logger_method_in_call_chain, ActionController::Base)}
      ActiveSupport.on_load(:active_record)     {debugger; TaggedLogger.send(:inject_logger_method_in_call_chain, ActiveRecord::Base)}
      ActiveSupport.on_load(:action_mailer)     {debugger; TaggedLogger.send(:inject_logger_method_in_call_chain, ActionMailer::Base)}
    end
  end
end


