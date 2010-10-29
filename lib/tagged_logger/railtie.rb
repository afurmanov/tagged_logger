if defined?(Rails::Railtie)
  module TaggedLogger
    class Railtie < Rails::Railtie
      ActiveSupport.on_load(:action_controller) do
        TaggedLogger.send(:inject_logger_method_in_call_chain, ActionController::Base)
        TaggedLogger.send(:inject_logger_method_in_call_chain, ActionController::LogSubscriber)
        TaggedLogger.rename [ActionController::LogSubscriber] => "action_controller.instrumentation"
      end
      ActiveSupport.on_load(:active_record) do
        TaggedLogger.send(:inject_logger_method_in_call_chain, ActiveRecord::Base)
        TaggedLogger.send(:inject_logger_method_in_call_chain, ActiveRecord::LogSubscriber)
        TaggedLogger.rename [ActiveRecord::LogSubscriber] => "active_record.instrumentation"
      end
      ActiveSupport.on_load(:action_mailer) do
        TaggedLogger.send(:inject_logger_method_in_call_chain, ActionMailer::Base)
        TaggedLogger.send(:inject_logger_method_in_call_chain, ActionMailer::LogSubscriber)
        TaggedLogger.rename [ActionMailer::LogSubscriber] => "action_mailer.instrumentation"
      end
      ActiveSupport.on_load(:action_view) do
        TaggedLogger.send(:inject_logger_method_in_call_chain, ActionView::LogSubscriber)
        TaggedLogger.rename [ActionView::LogSubscriber] => "action_view.instrumentation"
      end
    end
  end
end


