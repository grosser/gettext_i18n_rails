require 'spec_helper'

describe GettextI18nRails::Railtie do
  describe 'auto-reload configuration' do
    it 'can be set to true or false' do
      config = GettextI18nRails::Railtie.config.gettext_i18n_rails
      config.auto_reload = true
      config.auto_reload.should == true
    end

    it 'can be disabled' do
      config = GettextI18nRails::Railtie.config.gettext_i18n_rails
      config.auto_reload = false
      config.auto_reload.should == false
    end
  end
end
