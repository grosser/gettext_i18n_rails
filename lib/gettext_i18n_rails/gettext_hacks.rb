#overwriting I18n would be easier, but it is not possible as far as i have tried..
module FastGettext
  def locale_with_i18n=(new_locale)
    #these 2 are NOT chainable!
    FastGettext.locale_without_i18n = new_locale
    I18n.locale = FastGettext.locale.to_sym
  end
  alias_method_chain :locale=, :i18n
end