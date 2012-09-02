module GettextI18nRails
  module GettextHooks
    # shoarter call / maybe the interface changes again ...
    def self.add_parser(parser)
      xgettext.add_parser(parser)
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
