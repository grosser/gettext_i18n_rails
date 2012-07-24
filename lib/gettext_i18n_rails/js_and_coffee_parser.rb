require 'gettext/utils'
begin
  require 'gettext/tools/rgettext'
rescue LoadError #version prior to 2.0
  require 'gettext/rgettext'
end

module GettextI18nRails
  class JsAndCoffeeParser
    
    class << self
      # The gettext function name can be configured at the module level as js_gettext_function
      # This is to provide a way to avoid conflicts with other javascript libraries.
      # You only need to define the base function name to replace '_' and all the 
      # other variants (s_, n_, N_) will be deduced automatically.
      attr_accessor :js_gettext_function
    end
    self.js_gettext_function = '__'

    def self.target?(file)
      ['.js', '.coffee'].include?(File.extname(file))
    end

    # We're lazy and klumsy, so this is a regex based parser that looks for
    # invocations of the various gettext functions. Once captured, we
    # scan them once again to fetch all the function arguments.
    # Invoke regex captures like this:
    # source: "#{ __('hello') } #{ __("wor)ld") }"
    # matches:
    # [0]: __('hello')
    # [1]: __
    # [2]: 'hello'
    #
    # source: __('item', 'items', 33)
    # matches:
    # [0]: __('item', 'items', 33)
    # [1]: __
    # [2]: 'item', 'items', 33
    def self.parse(file, msgids = [])
      _ = self.js_gettext_function

      # We first parse full invocations 
      invoke_regex = /
        ([snN]?#{_})                 # Matches the function call grouping the method used (__, n__, N__, etc)
          \(                         # and a parenthesis to start the arguments to the function.
            (('.*?'|                 # Then a token inside the argument list, like a single quoted string
              ".*?"|                 # ...Double quote string
              [a-zA-Z0-9_\.()]*|     # ...a number, variable name, or called function lik: 33, foo, Foo.bar()
              [ ]|                   # ...a white space
              ,)                     # ...or a comma, which separates all of the above.
            *)                       # There may be many arguments to the same function call.
          \)         # function call closing parenthesis
      /x

      File.read(file).scan(invoke_regex).collect do |function, arguments|
        separator = function == "n#{_}" ? "\000" : "\004"
        key = arguments.scan(/('(?:[^'\\]|\\.)*'|"(?:[^"\\]|\\.)*")/)
          .collect{|match| match.first[1..-2]}
          .join(separator)
        next if key == ''
        key.gsub!("\n", '\n')
        key.gsub!("\t", '\t')
        key.gsub!("\0", '\0')
          
        [key, "#{file}:1"]
      end.compact
    end

  end
end
