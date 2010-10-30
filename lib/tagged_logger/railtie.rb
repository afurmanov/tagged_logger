if defined?(Rails::Railtie)
  module TaggedLogger
    class Railtie < Rails::Railtie
      ActiveSupport.on_load(:action_controller) do
        TaggedLogger.patch_logger(ActionController::Base, TaggedLogger.options[:replace_existing_logger]).
          patch_logger(ActionController::LogSubscriber, TaggedLogger.options[:replace_existing_logger]).
          rename [ActionController::LogSubscriber] => "action_controller.logsubscriber"
      end
      ActiveSupport.on_load(:active_record) do
        TaggedLogger.patch_logger(ActiveRecord::Base, TaggedLogger.options[:replace_existing_logger]).
          patch_logger(ActiveRecord::LogSubscriber, TaggedLogger.options[:replace_existing_logger]).
          rename [ActiveRecord::LogSubscriber] => "active_record.logsubscriber"
      end
      ActiveSupport.on_load(:action_mailer) do
        TaggedLogger.patch_logger(ActionMailer::Base, TaggedLogger.options[:replace_existing_logger]).
          patch_logger(ActionMailer::LogSubscriber, TaggedLogger.options[:replace_existing_logger]).
          rename [ActionMailer::LogSubscriber] => "action_mailer.logsubscriber"
      end
      ActiveSupport.on_load(:action_view) do
        TaggedLogger.patch_logger(ActionView::LogSubscriber, TaggedLogger.options[:replace_existing_logger]).
          rename [ActionView::LogSubscriber] => "action_view.logsubscriber"
      end
      ActiveSupport.on_load(:after_initialize) do
        TaggedLogger.patch_logger(Rails::Rack::Logger, TaggedLogger.options[:replace_existing_logger]).
          rename [Rails::Rack::Logger] => "rack.logsubscriber"
      end
      
    end
  end
end


