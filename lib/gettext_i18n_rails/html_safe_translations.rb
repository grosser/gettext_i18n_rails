module GettextI18nRails
  module HtmlSafeTranslations
    def self.included(base)
      base.extend self
    end

    def _(*args)
      super(*args).to_s.html_safe
    end

    def n_(*args)
      super(*args).to_s.html_safe
    end

    def s_(*args)
      super(*args).to_s.html_safe
    end
  end
end