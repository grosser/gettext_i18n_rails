require 'gettext_i18n_rails/version'

module GettextI18nRails
  extend self
end

require 'fast_gettext'
if Gem::Version.new(FastGettext::VERSION) < Gem::Version.new("0.4.8")
  raise "Please upgrade fast_gettext"
end

# include translations into all the places it needs to go...
Object.send(:include, FastGettext::Translation)

# make translations html_safe if possible and wanted
if "".respond_to?(:html_safe?)
  require 'gettext_i18n_rails/html_safe_translations'
  Object.send(:include, GettextI18nRails::HtmlSafeTranslations)
end

require 'gettext_i18n_rails/backend'
I18n.backend = GettextI18nRails::Backend.new

require 'gettext_i18n_rails/i18n_hacks'

if defined? Rails::Railtie # Rails 3+
  # load active_model extensions at the correct point in time
  require 'gettext_i18n_rails/railtie'
else
  if defined? ActiveRecord
    require 'gettext_i18n_rails/active_record'
  elsif defined?(ActiveModel)
    require 'gettext_i18n_rails/active_model'
  end
end

require 'gettext_i18n_rails/action_controller' if defined?(ActionController) # so that bundle console can work in a rails project

if defined? Rails::Engine # Rails 3+
  require 'gettext_i18n_rails/engine'
end
