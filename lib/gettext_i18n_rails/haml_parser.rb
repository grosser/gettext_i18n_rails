require 'gettext_i18n_rails/base_parser'

module GettextI18nRails
  class HamlParser < BaseParser
    def self.extension
      "haml"
    end

    def self.convert_to_code(text)
      Haml::Engine.new(text).precompiled()
    end
  end
end

GettextI18nRails::GettextHooks.add_parser GettextI18nRails::HamlParser
