require 'spec_helper'
require 'gettext_i18n_rails/slim_parser'

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
        parser.parse(path, []).should == [
          ["xxxx", "#{path}:1"]
        ]
      end
    end

    it "does not find messages in text" do
      with_file 'div _("xxxx")' do |path|
        parser.parse(path, []).should == []
      end
    end
  end
end