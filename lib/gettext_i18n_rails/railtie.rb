# add rake tasks if we are inside Rails
if defined?(Rails::Railtie)
  module GettextI18nRails
    class Railtie < ::Rails::Railtie
      config.gettext_i18n_rails = ActiveSupport::OrderedOptions.new
      config.gettext_i18n_rails.msgmerge = %w[--sort-output --no-location --no-wrap]
      rake_tasks do
        require 'gettext_i18n_rails/tasks'
      end
    end
  end
end
