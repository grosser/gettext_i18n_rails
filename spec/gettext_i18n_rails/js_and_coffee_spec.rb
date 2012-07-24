require "spec_helper"
require "gettext_i18n_rails/js_and_coffee_parser"

describe GettextI18nRails::JsAndCoffeeParser do
  let(:parser){ GettextI18nRails::JsAndCoffeeParser }

  describe "#target?" do
    it "targets .js" do
      parser.target?('foo/bar/xxx.js').should == true
    end

    it "targets .coffee" do
      parser.target?('foo/bar/xxx.coffee').should == true
    end

    it "does not target cows" do
      parser.target?('foo/bar/xxx.cows').should == false
    end
  end

  describe "#parse" do
    it "finds messages in coffee" do
      with_file 'foo = __("xxxx")' do |path|
        parser.parse(path, []).should == [
          ["xxxx", "#{path}:1"]
        ]
      end
    end

    it "finds plural messages in coffee" do
      with_file 'bla = n__("xxxx", "yyyy", "zzzz", some_count)' do |path|
        parser.parse(path, []).should == [
          ["xxxx\000yyyy\000zzzz", "#{path}:1"]
        ]
      end
    end

    it "finds namespaced messages in coffee" do
      with_file 'bla = __("xxxx", "yyyy")' do |path|
        parser.parse(path, []).should == [
          ["xxxx\004yyyy", "#{path}:1"]
        ]
      end
    end
    
    it 'Does find messages in interpolated multi-line strings' do
      source = '''
        """ Parser should grab
          #{ __(\'This\') } __(\'known bug\')
        """
      '''
      with_file source do |path|
        parser.parse(path, []).should == [
          ["This", "#{path}:1"],
          ["known bug", "#{path}:1"]
        ]
      end
    end
    
    it 'finds messages with newlines and tabs in them' do
      with_file 'bla = __("xxxx\n\t")' do |path|
        parser.parse(path, []).should == [
          ['xxxx\n\t', "#{path}:1"]
        ]
      end
    end

    it 'does not find messages that are not strings' do
      with_file 'bla = __(bar)' do |path|
        parser.parse(path, []).should == []
      end
    end

    it 'does not parse internal parentheses ' do
      with_file 'bla = __("some text (which is great) and some parentheses()") + __(\'foobar\')' do |path|
        parser.parse(path, []).should == [
          ['some text (which is great) and some parentheses()', "#{path}:1"],
          ['foobar', "#{path}:1"]
        ]
      end
    end
    it 'does not parse internal called functions' do
      with_file 'bla = n__("items (single)", "items (more)", item.count()) + __(\'foobar\')' do |path|
        parser.parse(path, []).should == [
          ["items (single)\000items (more)", "#{path}:1"],
          ['foobar', "#{path}:1"]
        ]
      end
    end

    it 'finds messages with newlines and tabs in them (single quotes)' do
      with_file "bla = __('xxxx\\n\\t')" do |path|
        parser.parse(path, []).should == [
          ['xxxx\n\t', "#{path}:1"]
        ]
      end
    end
    it 'finds strings that use some templating' do
      with_file '__("hello {yourname}")' do |path|
        parser.parse(path, []).should == [
          ['hello {yourname}', "#{path}:1"]
        ]
      end
    end
    it 'finds strings that use escaped strings' do
      with_file '__("hello \"dude\"") + __(\'how is it \\\'going\\\' \')' do |path|
        parser.parse(path, []).should == [
          ['hello \"dude\"', "#{path}:1"],
          ["how is it \\'going\\' ", "#{path}:1"]
        ]
      end
    end
    it 'accepts changing the function name' do
      GettextI18nRails::JsAndCoffeeParser.js_gettext_function = 'gettext'
      with_file 'gettext("hello {yourname}") + ngettext("item", "items", 44)' do |path|
        parser.parse(path, []).should == [
          ['hello {yourname}', "#{path}:1"],
          ["item\000items", "#{path}:1"],
        ]
      end
      GettextI18nRails::JsAndCoffeeParser.js_gettext_function = '__'
    end
  end
  
  describe 'mixed use tests' do
    it 'parses a full js file' do
      path = File.join(File.dirname(__FILE__), '../fixtures/example.js')
      parser.parse(path, []).should == [
        ['json', "#{path}:1"],
        ["item\000items", "#{path}:1"],
        ['hello {yourname}', "#{path}:1"],
        ['new-trans', "#{path}:1"],
        ["namespaced\004trans", "#{path}:1"],
        ['Hello\nBuddy', "#{path}:1"]
      ]
    end
    it 'parses a full coffee file' do
      path = File.join(File.dirname(__FILE__), '../fixtures/example.coffee')
      parser.parse(path, []).should == [
        ['json', "#{path}:1"],
        ["item\000items", "#{path}:1"],
        ['hello {yourname}', "#{path}:1"],
        ['new-trans', "#{path}:1"],
        ["namespaced\004trans", "#{path}:1"],
        ['Hello\nBuddy', "#{path}:1"],
        ['Multi-line', "#{path}:1"]
      ]
    end
  end
end
