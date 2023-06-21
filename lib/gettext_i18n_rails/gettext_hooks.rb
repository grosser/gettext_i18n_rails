module GettextI18nRails
  module GettextHooks
    # shorter call / maybe the interface changes again ...
    def self.add_parser(parser)
      xgettext.add_parser(parser)
    end

    def self.xgettext
      @xgettext ||= begin
        require 'gettext/tools/xgettext'
        GetText::Tools::XGetText
      end
    end
  end
end
