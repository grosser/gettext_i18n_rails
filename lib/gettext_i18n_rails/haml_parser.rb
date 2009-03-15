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
      load_haml
      haml = Haml::Engine.new(IO.readlines(file).join)
      code = haml.precompiled.split(/$/)
      GetText::RubyParser.parse_lines(file, code, msgids)
    end

    def load_haml
      return if @haml_loaded
      begin
        require "#{RAILS_ROOT}/vendor/plugins/haml/lib/haml"
      rescue LoadError
        begin
          require 'haml'  # From gem
        rescue LoadError
          raise 'A haml file was found, but haml library could not be found...'
        end
      end
      @haml_loaded = true
    end
  end
end
GetText::RGetText.add_parser(GettextI18nRails::HamlParser)