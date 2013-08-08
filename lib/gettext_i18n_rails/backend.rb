module GettextI18nRails
  #translates i18n calls to gettext calls
  class Backend
    @@translate_defaults = true
    cattr_accessor :translate_defaults
    attr_accessor :backend

    RUBY19 = (RUBY_VERSION > "1.9")

    def initialize(*args)
      self.backend = I18n::Backend::Simple.new(*args)
    end

    def available_locales
      FastGettext.available_locales || []
    end

    def translate(locale, key, options)
      if gettext_key = gettext_key(key, options)
        translation =
          plural_translate(gettext_key, options) || FastGettext._(gettext_key)
        interpolate(translation, options)
      else
        result = backend.translate(locale, key, options)
        (RUBY19 and result.is_a?(String)) ? result.force_encoding("UTF-8") : result
      end
    end

    def method_missing(method, *args)
      backend.send(method, *args)
    end

    protected

    def gettext_key(key, options)
      flat_key = flatten_key key, options
      if FastGettext.key_exist?(flat_key)
        flat_key
      elsif self.class.translate_defaults
        [*options[:default]].each do |default|
          #try the scoped(more specific) key first e.g. 'activerecord.errors.my custom message'
          flat_key = flatten_key default, options
          return flat_key if FastGettext.key_exist?(flat_key)

          #try the short key thereafter e.g. 'my custom message'
          return default if FastGettext.key_exist?(default)
        end
        return nil
      end
    end

    def plural_translate(gettext_key, options)
      if options[:count]
        translation = FastGettext.n_(gettext_key, options[:count])
        discard_pass_through_key gettext_key, translation
      end
    end

    def discard_pass_through_key(key, translation)
      if translation == key
        nil
      else
        translation
      end
    end

    def interpolate(string, values)
      if string.respond_to?(:%)
        reserved_keys = if defined?(I18n::RESERVED_KEYS) # rails 3+
          I18n::RESERVED_KEYS
        else
          I18n::Backend::Base::RESERVED_KEYS
        end

        options = values.except(*reserved_keys)
        options.any? ? (string % options) : string
      else
        string
      end
    end

    def flatten_key key, options
      scope = [*(options[:scope] || [])]
      scope.empty? ? key.to_s : "#{scope*'.'}.#{key}"
    end
  end
end
