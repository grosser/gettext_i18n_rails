require 'gettext_i18n_rails/gettext_hooks'

module GettextI18nRails
  class BaseParser
    def self.target?(file)
      File.extname(file) == ".#{extension}"
    end

    def self.parse(file, _options = {}, msgids = [])
      return msgids unless load_library
      code = convert_to_code(File.read(file))
      RubyGettextExtractor.parse_string(code, msgids, file)
    rescue Racc::ParseError => e
      $stderr.puts "file ignored: ruby_parser cannot read #{extension} files with 1.9 syntax --- #{file}: (#{e.message.strip})"
      return msgids
    end

    def self.libraries
      [extension]
    end

    def self.load_library
      return true if @library_loaded

      loaded = libraries.detect do |library|
        begin
          require library
          true
        rescue LoadError
          false
        end
      end

      unless loaded
        puts "No #{extension} library could be found: #{libraries.join(" or ")}"

        return false
      end

      require 'gettext_i18n_rails/ruby_gettext_extractor'
      @library_loaded = loaded
    end
  end
end
