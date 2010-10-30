if defined?(Rails::Railtie)
  module TaggedLogger
    class Railtie < Rails::Railtie
      if TaggedLogger.options[:replace_existing_logger]
        ActiveSupport.on_load(:action_controller) do
          TaggedLogger.patch_logger(ActionController::Base, true).
            patch_logger(ActionController::LogSubscriber, true).
            rename [ActionController::LogSubscriber] => "action_controller.logsubscriber"
        end
        ActiveSupport.on_load(:active_record) do
          TaggedLogger.patch_logger(ActiveRecord::Base, true).
            patch_logger(ActiveRecord::LogSubscriber, true).
            rename [ActiveRecord::LogSubscriber] => "active_record.logsubscriber"
        end
        ActiveSupport.on_load(:action_mailer) do
          TaggedLogger.patch_logger(ActionMailer::Base, true).
            patch_logger(ActionMailer::LogSubscriber, true).
            rename [ActionMailer::LogSubscriber] => "action_mailer.logsubscriber"
        end
        ActiveSupport.on_load(:action_view) do
          TaggedLogger.patch_logger(ActionView::LogSubscriber, true).
            rename [ActionView::LogSubscriber] => "action_view.logsubscriber"
        end
      end
    end
  end
end


