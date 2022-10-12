require 'gettext_i18n_rails/base_parser'

module GettextI18nRails
  class HamlParser < BaseParser
    def self.extension
      "haml"
    end

    def self.convert_to_code(text)
      case @library_loaded
      when "haml"
        if Haml::VERSION.split('.').first.to_i <= 5
          Haml::Engine.new(text).precompiled()
        else
          Haml::Engine.new.call(text)
        end
      when "hamlit"
        Hamlit::Engine.new.call(text)
      end
    end

    def self.libraries
      ["haml", "hamlit"]
    end
  end
end

GettextI18nRails::GettextHooks.add_parser GettextI18nRails::HamlParser
