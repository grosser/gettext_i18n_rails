require 'gettext_i18n_rails/version'
require 'gettext_i18n_rails/gettext_hooks'

module GettextI18nRails
  IGNORE_TABLES = [/^sitemap_/, /_versions$/, 'schema_migrations', 'sessions', 'delayed_jobs']

  # Issue #207: model-name msgids changed from the humanized form
  # ("Big car") to the raw class name ("BigCar"), matching attributes.
  # The humanized form is still looked up as a fallback; warn once per
  # msgid so apps can migrate their .po files.
  def self.warn_legacy_model_msgid(legacy, current)
    @warned_legacy_model_msgids ||= {}
    return if @warned_legacy_model_msgids.key?(legacy)
    @warned_legacy_model_msgids[legacy] = true
    warn(
      "[gettext_i18n_rails] msgid #{legacy.inspect} is deprecated, " \
      "re-extract and translate #{current.inspect} instead " \
      "(https://github.com/grosser/gettext_i18n_rails/issues/207)"
    )
  end
end

# translate from everywhere
require 'fast_gettext'
Object.send(:include, FastGettext::Translation)

# make translations html_safe if possible and wanted
if "".respond_to?(:html_safe?)
  require 'gettext_i18n_rails/html_safe_translations'
  Object.send(:include, GettextI18nRails::HtmlSafeTranslations)
end

# set up the backend
require 'gettext_i18n_rails/backend'
I18n.backend = GettextI18nRails::Backend.new

# make I18n play nice with FastGettext
require 'gettext_i18n_rails/i18n_hacks'

# translate activerecord errors
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

# make bundle console work in a rails project
require 'gettext_i18n_rails/action_controller' if defined?(ActionController)
