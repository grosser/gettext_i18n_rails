module GettextI18nRails
  class Railtie < ::Rails::Railtie
    config.gettext_i18n_rails = ActiveSupport::OrderedOptions.new
    config.gettext_i18n_rails.msgmerge = nil
    config.gettext_i18n_rails.msgcat = nil
    config.gettext_i18n_rails.xgettext = nil
    config.gettext_i18n_rails.use_for_active_record_attributes = true
    config.gettext_i18n_rails.auto_reload_in_development = true

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

      # Auto-reload .po files in development when they change
      if app.config.gettext_i18n_rails.auto_reload_in_development && Rails.env.development?
        po_files = Dir[Rails.root.join("locale/**/*.{po,mo}")]

        reloader = ActiveSupport::FileUpdateChecker.new(po_files) do
          FastGettext.translation_repositories.each_value(&:reload)
          Rails.logger.info "Reloaded gettext translations"
        end

        app.executor.to_run do
          reloader.execute_if_updated
        end
      end
    end
  end
end
