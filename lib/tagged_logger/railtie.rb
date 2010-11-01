if defined?(Rails::Railtie)
  module TaggedLogger
    class Railtie < Rails::Railtie
      ActiveSupport.on_load(:action_controller) do
        if TaggedLogger.options[:replace_existing_logger]
          TaggedLogger.patch_logger(ActionController::Base, true).
            patch_logger(ActionController::LogSubscriber, true).
            rename [ActionController::LogSubscriber] => "action_controller.logsubscriber"
        end
      end
      ActiveSupport.on_load(:active_record) do
        if TaggedLogger.options[:replace_existing_logger]
          TaggedLogger.patch_logger(ActiveRecord::Base, true).
            patch_logger(ActiveRecord::LogSubscriber, true).
            rename [ActiveRecord::LogSubscriber] => "active_record.logsubscriber"
        end
      end
      ActiveSupport.on_load(:action_mailer) do
        if TaggedLogger.options[:replace_existing_logger]
          TaggedLogger.patch_logger(ActionMailer::Base, true).
            patch_logger(ActionMailer::LogSubscriber, true).
            rename [ActionMailer::LogSubscriber] => "action_mailer.logsubscriber"
        end
      end
      ActiveSupport.on_load(:action_view) do
        if TaggedLogger.options[:replace_existing_logger]
          TaggedLogger.patch_logger(ActionView::LogSubscriber, true).
            rename [ActionView::LogSubscriber] => "action_view.logsubscriber"
        end
      end
      ActiveSupport.on_load(:after_initialize) do
        if TaggedLogger.options[:replace_existing_logger]
          TaggedLogger.patch_logger(Rails::Rack::Logger, true).
            rename [Rails::Rack::Logger] => "rack.logsubscriber"
        end
      end
      
    end
  end
end


