require 'gettext/utils'
begin
  require 'gettext/tools/rgettext'
rescue LoadError #version prior to 2.0
  require 'gettext/rgettext'
end

require 'gettext_i18n_rails/haml_translation_extractor'
module GettextI18nRails
  module HamlParser
    module_function

    def target?(file)
      File.extname(file) == '.haml'
    end

    def parse(file, msgids = [])
      return msgids unless load_haml
      text = IO.readlines(file).join

      #first pass with real haml
      haml = Haml::Engine.new(text)
      code = haml.precompiled.split(/$/)
      msgids = GetText::RubyParser.parse_lines(file, code, msgids)

      #second pass with hacky haml parser
      code = HamlTranslationExtractor.parse(text)
      GetText::RubyParser.parse_lines(file, code, msgids)
    end

    def load_haml
      return true if @haml_loaded
      begin
        require "#{RAILS_ROOT}/vendor/plugins/haml/lib/haml"
      rescue LoadError
        begin
          require 'haml'  # From gem
        rescue LoadError
          puts "A haml file was found, but haml library could not be found, so nothing will be parsed..."
          return false
        end
      end
      @haml_loaded = true
    end
  end
end
GetText::RGetText.add_parser(GettextI18nRails::HamlParser)