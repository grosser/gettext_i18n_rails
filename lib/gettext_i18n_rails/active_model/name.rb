module ActiveModel
  Name.class_eval do
    def human(options={})
      _(@klass.humanize_class_name)
    end
  end
end
