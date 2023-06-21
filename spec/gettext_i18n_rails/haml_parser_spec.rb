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
          with_file '= _("xxxx")', '.haml' do |path|
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

        it "finds messages with concatenation" do
          with_file '= _("xxxx" + "yyyy" + "zzzz")', '.haml' do |path|
            po = parser.parse(path, {}, [])
            po.entries.should match_array([
              have_attributes({
                msgctxt: nil,
                msgid: "xxxxyyyyzzzz",
                type: :normal,
                references: ["#{path}:1"]
              })
            ])
          end
        end

        it "finds messages with context in haml" do
          with_file '= p_("My context", "idkey")', '.haml' do |path|
            po = parser.parse(path, {}, [])
            po.entries.should match_array([
              have_attributes({
                msgctxt: "My context",
                msgid: "idkey",
                type: :msgctxt,
                references: ["#{path}:1"]
              })
            ])
          end
        end

        it "should parse the 1.9 if ruby_version is 1.9" do
          if RUBY_VERSION =~ /^1\.9/ || RUBY_VERSION > "2"
            with_file '= _("xxxx", x: 1)', '.haml' do |path|
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
        end

        it "does not find messages in text" do
          with_file '_("xxxx")', '.haml' do |path|
            po = parser.parse(path, {}, [])
            po.entries.empty?.should == true
          end
        end

        it "does not include parser options into parsed output" do
          with_file '= _("xxxx")' do |path|
            GetText::RubyParser.stub(:new).and_return(double("mockparser", parse_source: []))
            parser.parse(path, { comment_tag: "TRANSLATORS:" })

            GetText::RubyParser.should have_received(:new).with(path, { comment_tag: "TRANSLATORS:" })
          end
        end
      end
    end
  end
end
