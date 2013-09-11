module ActiveModel
  Name.class_eval do
    def human(options={})
      if count = options[:count]
        n_(@klass.humanize_class_name, count)
      else
        _(@klass.humanize_class_name)
      end
    end
  end
end
