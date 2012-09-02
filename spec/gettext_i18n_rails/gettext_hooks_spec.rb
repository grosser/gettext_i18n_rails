require "spec_helper"

describe GettextI18nRails::GettextHooks do
  describe ".add_parsers_to_gettext" do
    def parsers
      GettextI18nRails::GettextHooks.xgettext # load XGetText
      GettextI18nRails::GettextHooks.instance_variable_set(:@add_parsers_to_gettext, nil) # can add_parsers_to_gettext multiple times
      GetText::Tools::XGetText.class_variable_get(:@@default_parsers)
    end

    before do
      parsers.clear
    end

    it "should add all parsers to gettext" do
      expect{
        GettextI18nRails::GettextHooks.add_parsers_to_gettext
      }.to change{ parsers.size }.by(+3)
    end

    it "should not add them twice" do
      expect{
        GettextI18nRails::GettextHooks.add_parsers_to_gettext
        GettextI18nRails::GettextHooks.add_parsers_to_gettext
      }.to change{ parsers.size }.by(+3)
    end
  end
end
