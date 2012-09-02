require 'gettext_i18n_rails/base_parser'

module GettextI18nRails
  class SlimParser < BaseParser
    def self.extension
      "slim"
    end

    def self.convert_to_code(text)
      Slim::Engine.new.call(text)
    end
  end
end

GettextI18nRails::GettextHooks.add_parser GettextI18nRails::SlimParser
