module GettextI18nRails
  #translates i18n calls to gettext calls
  class Backend
    @@translate_defaults = true
    cattr_accessor :translate_defaults
    attr_accessor :backend

    def initialize(*args)
      self.backend = I18n::Backend::Simple.new(*args)
    end

    def available_locales
      FastGettext.available_locales || []
    end

    def translate(locale, key, options)
      flat_key = flatten_key key, options
      if FastGettext.key_exist?(flat_key)
        raise "no yet build..." if options[:locale]
        interpolate(_(flat_key), options)
      else
        if self.class.translate_defaults
          [*options[:default]].each do |default|
            #try the more specific key first e.g. 'activerecord.errors.my custom message'
            flat_key = flatten_key default, options
            return interpolate(FastGettext._(flat_key), options) if FastGettext.key_exist?(flat_key)

            #try the short key thereafter e.g. 'my custom message'
            return interpolate(FastGettext._(default), options) if FastGettext.key_exist?(default)
          end
        end
        backend.translate locale, key, options
      end
    end

    def method_missing(method, *args)
      backend.send(method, *args)
    end

    protected

    def interpolate(string, values)
      string % values.except(*I18n::Backend::Base::RESERVED_KEYS)
    end

    def flatten_key key, options
      scope = [*(options[:scope] || [])]
      scope.empty? ? key.to_s : "#{scope*'.'}.#{key}"
    end
  end
end