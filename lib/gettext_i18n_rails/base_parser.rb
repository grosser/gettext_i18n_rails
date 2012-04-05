require 'gettext/utils'
begin
  require 'gettext/tools/rgettext'
rescue LoadError #version prior to 2.0
  require 'gettext/rgettext'
end

module GettextI18nRails
  class BaseParser
    def self.target?(file)
      File.extname(file) == ".#{extension}"
    end

    def self.parse(file, msgids = [])
      return msgids unless load_library
      code = convert_to_code(File.read(file))
      RubyGettextExtractor.parse_string(code, file, msgids)
    rescue Racc::ParseError => e
      $stderr.puts "file ignored: ruby_parser cannot read #{extension} files with 1.9 syntax --- (#{e.message})"
      return msgids
    end

    def self.load_library
      return true if @library_loaded

      begin
        require "#{::Rails.root.to_s}/vendor/plugins/#{extension}/lib/#{extension}"
      rescue LoadError
        begin
          require extension # From gem
        rescue LoadError
          puts "A #{extension} file was found, but #{extension} library could not be found, so nothing will be parsed..."
          return false
        end
      end

      require 'gettext_i18n_rails/ruby_gettext_extractor'
      @library_loaded = true
    end
  end
end
