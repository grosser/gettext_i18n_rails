module ActiveModel
  Name.class_eval do
    def human(options={})
      msgid = @klass.gettext_model_name_msgid

      if count = options[:count]
        n_(msgid, msgid.pluralize, count)
      else
        _(msgid)
      end
    end
  end
end
