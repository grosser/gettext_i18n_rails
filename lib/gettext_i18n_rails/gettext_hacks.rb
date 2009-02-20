module FastGettext
  def locale=(locales)
    locale =([*locales].detect{|l| FastGettext.available_locales.include?(l)})
    I18n.locale = (locale||'en').to_sym
  end

  def locale
    I18n.locale.to_s
  end
end