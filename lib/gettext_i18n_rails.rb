module GettextI18nRails
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip
  
  extend self
end

require 'fast_gettext'
if Gem::Version.new(FastGettext::VERSION) < Gem::Version.new("0.4.8")
  raise "Please upgrade fast_gettext"
end

# include translations into all the places it needs to go...
Object.send(:include,FastGettext::Translation)

require 'gettext_i18n_rails/backend'
I18n.backend = GettextI18nRails::Backend.new

require 'gettext_i18n_rails/i18n_hacks'
require 'gettext_i18n_rails/active_record'
require 'gettext_i18n_rails/action_controller'