module GettextI18nRails::ActiveRecord
  # CarDealer.sales_count -> s_('CarDealer|Sales count') -> 'Sales count' if no translation was found
  def human_attribute_name(attribute, *args)
    s_(gettext_translation_for_attribute_name(attribute))
  end

  # CarDealer -> _('car dealer')
  # method deprecated in Rails 3.1
  def human_name(*args)
    _(self.humanize_class_name(self.to_s))
  end

  def humanize_class_name(name)
    name.underscore.humanize
  end

  def gettext_translation_for_attribute_name(attribute)
    if attribute.to_s.ends_with?('_id')
      humanize_class_name(attribute)
    else
      "#{self}|#{attribute.to_s.split('.').map! {|a| a.humanize }.join('|')}"
    end
  end
end
