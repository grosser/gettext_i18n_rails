module GettextI18nRails
  module GettextHooks
    def self.add_parsers_to_gettext
      return if @add_parsers_to_gettext
      @add_parsers_to_gettext = true

      require "gettext_i18n_rails/haml_parser"
      require "gettext_i18n_rails/hamlet_parser"
      require "gettext_i18n_rails/slim_parser"

      GettextI18nRails::BaseParser.parser_descendants.each do |parser|
        xgettext.add_parser(parser)
      end
    end

    def self.xgettext
      @xgettext ||= begin
        require 'gettext/tools/xgettext' # 2.3+
        GetText::Tools::XGetText
      rescue LoadError
        begin
          require 'gettext/tools/rgettext' # 2.0 - 2.2
          GetText::RGetText
        rescue LoadError # # 1.x
          require 'gettext/rgettext'
          GetText::RGetText
        end
      end
    end
  end
end
