require 'spec_helper'

describe GettextI18nRails::Railtie do
  describe 'auto-reload configuration' do
    it 'enables auto_reload_in_development by default' do
      config = GettextI18nRails::Railtie.config.gettext_i18n_rails
      config.auto_reload_in_development.should == true
    end

    it 'can be disabled' do
      config = GettextI18nRails::Railtie.config.gettext_i18n_rails
      config.auto_reload_in_development = false
      config.auto_reload_in_development.should == false
    end
  end
end
