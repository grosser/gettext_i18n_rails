require 'gettext/tools'
begin
  require 'gettext/tools/rgettext'
rescue LoadError #version prior to 2.0
  require 'gettext/rgettext'
end

module GettextI18nRails
  module HamletParser
    module_function

    def target?(file)
      File.extname(file) == '.hamlet'
    end

    def parse(file, msgids = [])
      return msgids unless prepare_hamlet_parsing
      text = File.read(file)
      code = Hamlet::Engine.new.call(text)
      RubyGettextExtractor.parse_string(code, file, msgids)
    end

    def prepare_hamlet_parsing
      return true if @hamlet_loaded
      begin
        require 'hamlet'
      rescue LoadError
        puts "A hamlet file was found, but hamlet library could not be found, so nothing will be parsed..."
        return false
      end
      require 'gettext_i18n_rails/ruby_gettext_extractor'
      @hamlet_loaded = true
    end
  end
end

GetText::RGetText.add_parser(GettextI18nRails::HamletParser)

