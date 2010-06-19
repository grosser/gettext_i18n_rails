module I18n
  module_function
  # this is not chainable, since FastGettext may reject this locale!
  def locale=(new_locale)
    FastGettext.locale = new_locale

    # Between Rails 2.3.5 and 2.3.8 the way the current locale is maintained changed, now there's a config object
    # keeping the state. This is a quick hack and should probably be cleaned. For more information read this bug report:
    # http://github.com/grosser/fast_gettext/issues/#issue/5
    # Maybe a better solution should be found, something like conditional chaining.
    if FastGettext.locale.to_sym == new_locale.to_sym && self.respond_to?(:config)
      config.locale = new_locale
    end
  end

  def locale
    FastGettext.locale.to_sym
  end
end
