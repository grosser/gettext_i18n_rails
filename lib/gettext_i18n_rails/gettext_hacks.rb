require 'gettext/textdomain' #load it before we overwrite...
module GetText
  # use thread-save locale storage, that interacts with I18n.locale
  attr_accessor :available_locales

  def locale=(locales)
    locale = [*locales].detect{|l| available_locales.include?(l)}
    locale ||= available_locales.first
    I18n.locale=locale.to_sym
    locale
  end

  def locale
    I18n.locale.to_s
  end

  #too much wtf + conflic with simplified locale
  class TextDomain
    def load_mo(lang)
      lang = GetText.locale # lang passed in is 100, very helpful...

      mofile = @mofiles[lang]
      if mofile
        mofile.update! unless self.class.cached?
        return mofile
      end

      # find mo file in filesystem
      @locale_paths.each do |dir|
        fname = dir % {:lang => lang, :name => @name}
        if File.exist?(fname)
          mofile = MOFile.open(fname, "UTF-8")
          break
        end
      end

      #store if found, else empty
      return :empty unless mofile
      @mofiles[lang] = mofile
    end
  end
end