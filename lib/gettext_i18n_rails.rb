module GettextI18nRails
  extend self
end

begin
  gem 'grosser-fast_gettext', '>=0.2.10'
rescue LoadError
  gem 'fast_gettext', '>=0.2.10'
end

# include translations into all the places it needs to go...
Object.send(:include,FastGettext::Translation)

require 'gettext_i18n_rails/backend'
I18n.backend = GettextI18nRails::Backend.new

require 'gettext_i18n_rails/i18n_hacks'
require 'gettext_i18n_rails/active_record'
require 'gettext_i18n_rails/action_controller'