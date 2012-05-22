module GettextI18nRails::ActiveRecord
  # CarDealer.sales_count -> s_('CarDealer|Sales count') -> 'Sales count' if no translation was found
  def human_attribute_name(attribute, *args)
    s_(gettext_translation_for_attribute_name(attribute))
  end

  # method deprecated in Rails 3.1
  def human_name(*args)
    _(self.humanize_class_name)
  end

  def humanize_class_name(name=nil)
    name ||= self.to_s
    name.underscore.humanize
  end

  def gettext_translation_for_attribute_name(attribute)
    attribute = attribute.to_s
    if attribute.ends_with?('_id')
      humanize_class_name(attribute)
    else
      "#{self}|#{attribute.split('.').map! {|a| a.humanize }.join('|')}"
    end
  end
end
