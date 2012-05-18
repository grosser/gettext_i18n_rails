module ActiveModel
  class Name < String
    def human(options={})
      _(@klass.humanize_class_name(self))
    end
  end
end
