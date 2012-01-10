require 'gettext/utils'
begin
  require 'gettext/tools/rgettext'
rescue LoadError #version prior to 2.0
  require 'gettext/rgettext'
end

module GettextI18nRails
  module HamlParser
    module_function

    def target?(file)
      File.extname(file) == '.haml'
    end

    def parse(file, msgids = [])
      return msgids unless prepare_haml_parsing
      code = haml_to_code(File.read(file))
      RubyGettextExtractor.parse_string(code, file, msgids)
    end

    def haml_to_code(haml)
      Haml::Engine.new(haml).precompiled
    end

    def prepare_haml_parsing
      return true if @haml_loaded

      begin
        require "#{::Rails.root.to_s}/vendor/plugins/haml/lib/haml"
      rescue LoadError
        begin
          require 'haml'  # From gem
        rescue LoadError
          puts "A haml file was found, but haml library could not be found, so nothing will be parsed..."
          return false
        end
      end

      require 'gettext_i18n_rails/ruby_gettext_extractor'
      @haml_loaded = true
    end
  end
end
GetText::RGetText.add_parser(GettextI18nRails::HamlParser)