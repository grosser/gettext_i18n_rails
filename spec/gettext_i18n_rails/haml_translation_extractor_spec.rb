require File.expand_path("../spec_helper", File.dirname(__FILE__))

FastGettext.silence_errors
require 'gettext_i18n_rails/haml_parser'
describe 'HamlTranslationExtractor' do
  def parse(text)
    GettextI18nRails::HamlTranslationExtractor.parse(text)
  end

  it "finds a simple translation" do
    parse("#xxx=_('test')").should == ["_('test')"]
  end

  it "finds a pluralized translation" do
    parse("#xxx\n  =n_('test','tests')").should == ['',"n_('test','tests')"]
  end

  it "does not find broken translation through brace errors" do
    text = parse("#xxx=_('tes()t')")
    (text == [''] or text == ["_('tes()t')"]).should be_true
  end

  it "preserves empty lines" do
    parse(" \n \n _('test')").should == ['','',"_('test')"]
  end

  it "preserves empty lines for windows" do
    parse(" \r\n \r\n _('test')").should == ['','',"_('test')"]
  end

  it "does not parse commented out lines" do
    parse("-#  _('test')").should == ['']
  end

  it "does not parse indented commented out lines" do
    parse("-#\n  =_('test')").should == ['','']
  end

  it "does not parse doubely commented lines" do
    parse("-#\n  -#\n  =_('test')").should == ['','','']
  end

  it "parses lines after comments" do
    parse("-#\n  _('no')\n=_('test')").should == ['','',"_('test')"]
  end
end