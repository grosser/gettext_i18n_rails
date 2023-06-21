require "spec_helper"
require "gettext_i18n_rails/slim_parser"

describe GettextI18nRails::SlimParser do
  let(:parser){ GettextI18nRails::SlimParser }

  describe "#target?" do
    it "targets .slim" do
      parser.target?('foo/bar/xxx.slim').should == true
    end

    it "does not target anything else" do
      parser.target?('foo/bar/xxx.erb').should == false
    end
  end

  describe "#parse" do
    it "finds messages in slim" do
      with_file 'div = _("xxxx")' do |path|
        po = parser.parse(path, {}, [])
        po.entries.should match_array([
          have_attributes({
            msgctxt: nil,
            msgid: "xxxx",
            type: :normal,
            references: ["#{path}:1"]
          })
        ])
      end
    end

    it "can parse 1.9 syntax" do
      with_file 'div = _("xxxx", foo: :bar)' do |path|
        po = parser.parse(path, {}, [])
        po.entries.should match_array([
          have_attributes({
            msgctxt: nil,
            msgid: "xxxx",
            type: :normal,
            references: ["#{path}:1"]
          })
        ])
      end
    end

    it "does not find messages in text" do
      with_file 'div _("xxxx")' do |path|
        po = parser.parse(path, {}, [])
        po.entries.empty?.should == true
      end
    end
  end
end
