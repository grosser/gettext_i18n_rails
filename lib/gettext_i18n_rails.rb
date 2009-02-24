# include translations into all the places it needs to go...
[ActiveRecord::Base,ActionController::Base,ActionView::Base,ActionMailer::Base].each do |clas|
  clas.send(:include,FastGettext::Translation)
  clas.send(:extend,FastGettext::Translation) #remove when fast_gettext 0.2.8 is availble
end

I18n.backend = I18n::Backend::Simple.new

require 'gettext_i18n_rails/gettext_hacks'
require 'gettext_i18n_rails/active_record'
require 'gettext_i18n_rails/action_controller'

module GettextI18nRails
  extend self
end