class ActiveRecord::Base
  # CarDealer.sales_count -> s_('CarDealer|Sales count') -> 'Sales count' if no translation was found
  def self.human_attribute_name(attribute)
    s_(gettext_translation_for_attribute_name(attribute))
  end

  # CarDealer -> _('CarDealer')
  def self.human_name
    _(self.to_s)
  end

  private

  def self.gettext_translation_for_attribute_name(attribute,clas=self)
    "#{clas}|#{attribute.to_s.gsub('_',' ').capitalize}"
  end
end