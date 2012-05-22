module GettextI18nRails::ActiveRecord
  include ActiveModel::Translation

  # method deprecated in Rails 3.1
  def human_name(*args)
    _(self.humanize_class_name)
  end
end
