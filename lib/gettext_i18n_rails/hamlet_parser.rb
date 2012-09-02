require 'gettext_i18n_rails/base_parser'

module GettextI18nRails
  class HamletParser < BaseParser
    def self.extension
      "hamlet"
    end

    def self.convert_to_code(text)
      Hamlet::Engine.new.call(text)
    end
  end
end
