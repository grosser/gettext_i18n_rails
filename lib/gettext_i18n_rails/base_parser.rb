require 'gettext_i18n_rails/gettext_hooks'

module GettextI18nRails
  class BaseParser
    def self.target?(file)
      File.extname(file) == ".#{extension}"
    end

    def self.parse(file, options = {}, _msgids = [])
      return _msgids unless load_library
      code = convert_to_code(File.read(file))
      GetText::RubyParser.new(file, options).parse_source(code)
    end

    def self.libraries
      [extension]
    end

    def self.load_library
      return true if @library_loaded

      loaded = libraries.detect do |library|
        if Gem::Specification.find_all_by_name(library).any?
          require library
          true
        else
          false
        end
      end

      unless loaded
        puts "No #{extension} library could be found: #{libraries.join(" or ")}"

        return false
      end

      require 'gettext/tools/parser/ruby'
      @library_loaded = loaded
    end
  end
end
