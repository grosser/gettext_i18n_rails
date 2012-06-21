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

    it "ignores 1.9 errors and shows the paths of offending files" do
      with_file '= _("xxxx", x: 1)' do |path|
        $stderr.should_receive(:puts).with{|x| x =~ /file ignored.*#{path}/ }
        parser.parse(path, [1]).should == [1]
      end
    end

    it "does not find messages in text" do
      with_file '_("xxxx")' do |path|
        parser.parse(path, []).should == []
      end
    end
  end
end
