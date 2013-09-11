require 'gettext_i18n_rails/active_model/translation'

class ActiveRecord::Base
  extend ActiveModel::Translation

  def self.human_attribute_name(*args)
    super(*args)
  end

  # method deprecated in Rails 3.1
  def self.human_name(*args)
    model_name.human(*args)
  end
end
