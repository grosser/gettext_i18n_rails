module GettextI18nRails
  #translates i18n calls to gettext calls
  class Backend
    def initialize(*args)
      @backend = I18n::Backend::Simple.new(*args)
    end

    def available_locales
      FastGettext.available_locales || []
    end

    def translate(locale, key, options)
      flat_key = flatten_key key, options
      if FastGettext.key_exist?(flat_key)
        raise "no yet build..." if options[:locale]
        _(flat_key)
      else
        @backend.translate locale, key, options
      end
    end

    def method_missing(method, *args)
      @backend.call(method, *args)
    end

    protected

    def flatten_key key, options
      scope = options[:scope] || []
      scope.empty? ? key.to_s : "#{scope*'.'}.#{key}"
    end
  end
end