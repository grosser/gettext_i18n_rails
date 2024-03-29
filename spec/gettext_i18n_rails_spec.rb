require "spec_helper"

FastGettext.silence_errors

describe GettextI18nRails do
  before do
    GettextI18nRails.translations_are_html_safe = nil
  end

  it "extends all classes with fast_gettext" do
    _('test')
  end

  describe 'translations_are_html_safe' do
    before do
      GettextI18nRails.translations_are_html_safe = nil
    end

    it "makes translations not html_safe by default" do
      _('x').html_safe?.should == false
      s_('x').html_safe?.should == false
      n_('x','y',2).html_safe?.should == false
      String._('x').html_safe?.should == false
      String.s_('x').html_safe?.should == false
      String.n_('x','y',2).html_safe?.should == false
    end

    it "makes instance translations html_safe when wanted" do
      GettextI18nRails.translations_are_html_safe = true
      _('x').html_safe?.should == true
      s_('x').html_safe?.should == true
      n_('x','y',2).html_safe?.should == true
    end

    it "makes class translations html_safe when wanted" do
      GettextI18nRails.translations_are_html_safe = true
      String._('x').html_safe?.should == true
      String.s_('x').html_safe?.should == true
      String.n_('x','y',2).html_safe?.should == true
    end

    it "does not make everything html_safe" do
      'x'.html_safe?.should == false
    end
  end

  it "sets up out backend" do
    I18n.backend.is_a?(GettextI18nRails::Backend).should == true
  end

  it "has a VERSION" do
    GettextI18nRails::VERSION.should =~ /^\d+\.\d+\.\d+$/
  end

  describe 'FastGettext I18n interaction' do
    before do
      FastGettext.available_locales = nil
      FastGettext.locale = 'de'
    end

    it "links FastGettext with I18n locale" do
      FastGettext.locale = 'xx'
      I18n.locale.should == :xx
    end

    it "does not set an not-accepted locale to I18n.locale" do
      FastGettext.available_locales = ['de']
      FastGettext.locale = 'xx'
      I18n.locale.should == :de
    end

    it "links I18n.locale and FastGettext.locale" do
      I18n.locale = :yy
      FastGettext.locale.should == 'yy'
    end

    it "does not set a non-available locale though I18n.locale" do
      FastGettext.available_locales = ['de']
      I18n.locale = :xx
      FastGettext.locale.should == 'de'
      I18n.locale.should == :de
    end

    it "converts gettext to i18n style for nested locales" do
      FastGettext.available_locales = ['de_CH']
      I18n.locale = :"de-CH"
      FastGettext.locale.should == 'de_CH'
      I18n.locale.should == :"de-CH"
    end
  end

  describe "GetText PO file creation" do
    before do
      require "gettext_i18n_rails/haml_parser"
      require "gettext_i18n_rails/slim_parser"
    end

    it "parses haml" do
      haml_content = <<~EOR
        = _("xxxx")
        = p_("Context", "key")
        _("JustText")
      EOR
      with_file haml_content, '.haml' do |path|
        po = GettextI18nRails::GettextHooks.xgettext.new.parse(path)
        po.entries.should match_array([
          have_attributes({
            msgctxt: nil,
            msgid: "xxxx",
            type: :normal,
            references: ["#{path}:1"]
          }),
          have_attributes({
            msgctxt: "Context",
            msgid: "key",
            type: :msgctxt,
            references: ["#{path}:2"]
          })
        ])
      end
    end

    it "parses slim" do
      slim_content = <<~EOR
        div = _("xxxx")
        div = p_("Context", "key")
        div _("JustText")
      EOR
      with_file slim_content, '.slim' do |path|
        po = GettextI18nRails::GettextHooks.xgettext.new.parse(path)
        po.entries.should match_array([
          have_attributes({
            msgctxt: nil,
            msgid: "xxxx",
            type: :normal,
            references: ["#{path}:1"]
          }),
          have_attributes({
            msgctxt: "Context",
            msgid: "key",
            type: :msgctxt,
            references: ["#{path}:2"]
          })
        ])
      end
    end
  end
end
