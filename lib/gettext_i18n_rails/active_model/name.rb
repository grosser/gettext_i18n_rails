module ActiveModel
  Name.class_eval do
    def human(options={})
      human_name = @klass.humanize_class_name

      if count = options[:count]
        n_(human_name, human_name.pluralize, count)
      else
        _(human_name)
      end
    end
  end
end
