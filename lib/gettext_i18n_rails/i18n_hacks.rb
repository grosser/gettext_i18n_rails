I18n::Config # autoload

module I18n
  class Config
    def locale
      FastGettext.locale.gsub("_","-").to_sym
    end

     def locale=(new_locale)
      FastGettext.locale=(new_locale)
    end
  end

  # backport I18n.with_locale if it does not exist
  # Executes block with given I18n.locale set.
  def self.with_locale(tmp_locale = nil)
    if tmp_locale
      current_locale = self.locale
      self.locale = tmp_locale
    end
    yield
  ensure
    self.locale = current_locale if tmp_locale
  end unless defined? I18n.with_locale
end
