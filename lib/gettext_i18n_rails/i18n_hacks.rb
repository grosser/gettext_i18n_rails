module I18n
  module_function

  def locale=(new_locale)
    FastGettext.locale = new_locale
  end

  def locale
    FastGettext.locale.to_sym
  end

  # since Rails 2.3.8 a config object is used instead of just .locale
  if defined? Config
    class Config
      def locale
        FastGettext.locale.to_sym
      end

       def locale=(new_locale)
        FastGettext.locale=(new_locale)
      end
    end
  end
end