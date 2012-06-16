# if running Rails 2 ActiveModel won't exist -- but we still need to load
# our overrides for the include below to work
begin
  require 'active_model'
rescue LoadError
  require 'gettext_i18n_rails/active_model'
end

module GettextI18nRails::ActiveRecord
  include ActiveModel::Translation

  def self.included(base)
    base.class_eval do
      def self.human_attribute_name(*args)
        super(*args)
      end

      # method deprecated in Rails 3.1
      def self.human_name(*args)
        _(self.humanize_class_name)
      end
    end
  end
end
