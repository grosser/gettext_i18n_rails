require 'gettext/utils'
begin
  require 'gettext/tools/rgettext'
rescue LoadError #version prior to 2.0
  require 'gettext/rgettext'
end

module GettextI18nRails
  module SlimParser
    module_function

    def target?(file)
      File.extname(file) == '.slim'
    end

    def parse(file, msgids = [])
      return msgids unless load_slim
      require 'gettext_i18n_rails/ruby_gettext_extractor'

      text = File.read(file)

      slim = Slim::Template.new { text }
      code = slim.precompiled_template
      return RubyGettextExtractor.parse_string(code, file, msgids)
    end

    def load_slim
      return true if @slim_loaded
      begin
        require 'slim'  # From gem
      rescue LoadError
        puts "A slim file was found, but slim library could not be found, so nothing will be parsed..."
        return false
      end
      @slim_loaded = true
    end
  end
end
GetText::RGetText.add_parser(GettextI18nRails::SlimParser)
