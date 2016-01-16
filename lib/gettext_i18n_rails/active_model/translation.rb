module ActiveModel
  module Translation
    # CarDealer.sales_count -> s_('CarDealer|Sales count') -> 'Sales count' if no translation was found
    def human_attribute_name(attribute, *args)
      s_(gettext_translation_for_attribute_name(attribute))
    end

    def gettext_translation_for_attribute_name(attribute)
      attribute = attribute.to_s
      if attribute.ends_with?('_id')
        humanize_class_name(attribute)
      else
        "#{inheritance_tree_root(self)}|#{attribute.split('.').map! {|a| a.humanize }.join('|')}"
      end
    end

    def inheritance_tree_root(aclass)
      return aclass unless aclass.respond_to?(:base_class)
      base = aclass.base_class
      if base.superclass.abstract_class?
        if defined?(::ApplicationRecord) && base.superclass == ApplicationRecord
          base
        else
          base.superclass
        end
      else
        base
      end
    end

    def humanize_class_name(name=nil)
      name ||= self.to_s
      name.underscore.humanize
    end
  end
end
