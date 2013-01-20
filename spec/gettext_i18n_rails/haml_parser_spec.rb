require "spec_helper"
require "gettext_i18n_rails/haml_parser"

describe GettextI18nRails::HamlParser do
  let(:parser){ GettextI18nRails::HamlParser }

  describe "#target?" do
    it "targets .haml" do
      parser.target?('foo/bar/xxx.haml').should == true
    end

    it "does not target anything else" do
      parser.target?('foo/bar/xxx.erb').should == false
    end
  end

  describe "#parse" do
    it "finds messages in haml" do
      with_file '= _("xxxx")' do |path|
        parser.parse(path, []).should == [
          ["xxxx", "#{path}:1"]
        ]
      end
    end

    it "should parse the 1.9" do
      with_file '= _("xxxx", x: 1)' do |path|
        parser.parse(path, []).should == [
          ["xxxx", "#{path}:1"]
        ]
      end
    end

    it "does not find messages in text" do
      with_file '_("xxxx")' do |path|
        parser.parse(path, []).should == []
      end
    end
  end
end
