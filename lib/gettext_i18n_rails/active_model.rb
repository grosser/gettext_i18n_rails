module ActiveModel
  class Name < String
    def human(options={})
      _(@klass.humanize_class_name)
    end
  end
end
