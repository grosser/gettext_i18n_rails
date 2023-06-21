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
    ["haml", "hamlit"].each do |library|
      context "with #{library} library only" do
        before do
          GettextI18nRails::HamlParser.stub(:libraries).and_return([library])
          GettextI18nRails::HamlParser.instance_variable_set(:@library_loaded, false)
        end

        it "finds messages in haml" do
          with_file '= _("xxxx")' do |path|
            parser.parse(path, {}, []).should == [
              ["xxxx", "#{path}:1"]
            ]
          end
        end

        it "finds messages with concatenation" do
          with_file '= _("xxxx" + "yyyy" + "zzzz")' do |path|
            parser.parse(path, {}, []).should == [
              ["xxxxyyyyzzzz", "#{path}:1"]
            ]
          end
        end

        it "should parse the 1.9 if ruby_version is 1.9" do
          if RUBY_VERSION =~ /^1\.9/ || RUBY_VERSION > "2"
            with_file '= _("xxxx", x: 1)' do |path|
              parser.parse(path, {}, []).should == [
                ["xxxx", "#{path}:1"]
              ]
            end
          end
        end

        it "does not find messages in text" do
          with_file '_("xxxx")' do |path|
            parser.parse(path, {}, []).should == []
          end
        end

        it "does not include parser options into parsed output" do
          with_file '= _("xxxx")' do |path|
            parser.parse(path, {:option => "value"}).should_not include([:option, "value"])
          end
        end
      end
    end
  end
end
