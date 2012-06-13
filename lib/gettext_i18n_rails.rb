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

require 'gettext_i18n_rails/active_record'
# If configuration via Railties is not available force activerecord extensions
if not defined?(Rails::Railtie) and defined?(ActiveRecord)
  ActiveRecord::Base.extend GettextI18nRails::ActiveRecord
end

if not defined?(Rails::Railtie) and defined?(ActiveModel)
  require 'gettext_i18n_rails/active_model'
  ActiveRecord::Base.extend ActiveModel::Translation
end

require 'gettext_i18n_rails/action_controller' if defined?(ActionController) # so that bundle console can work in a rails project
require 'gettext_i18n_rails/railtie'
