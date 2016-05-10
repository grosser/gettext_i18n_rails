module GettextI18nRails
  class Railtie < ::Rails::Railtie
    config.gettext_i18n_rails = ActiveSupport::OrderedOptions.new
    config.gettext_i18n_rails.msgmerge = nil
    config.gettext_i18n_rails.msgcat = nil
    config.gettext_i18n_rails.xgettext = nil
    config.gettext_i18n_rails.use_for_active_record_attributes = true

    rake_tasks do
      if Gem::Specification.find_all_by_name("gettext", ">= 3.0.2").any?
        require 'gettext_i18n_rails/tasks'
      end
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
