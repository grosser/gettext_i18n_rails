module GettextI18nRails
  class Railtie < ::Rails::Railtie
    config.gettext_i18n_rails = ActiveSupport::OrderedOptions.new
    config.gettext_i18n_rails.msgmerge = nil
    config.gettext_i18n_rails.xgettext = nil
    config.gettext_i18n_rails.use_for_active_record_attributes = true

    rake_tasks do
      require 'gettext_i18n_rails/tasks'
    end

    config.after_initialize do |app|
      if app.config.gettext_i18n_rails.use_for_active_record_attributes
        ActiveSupport.on_load :active_record do
          require 'gettext_i18n_rails/active_model'
        end
      end
    end
  end
end
