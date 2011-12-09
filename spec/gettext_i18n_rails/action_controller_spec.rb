require File.expand_path("../spec_helper", File.dirname(__FILE__))

FastGettext.silence_errors

describe ActionController::Base do
  def reset!
    fake_session = {}
    @c.stub!(:session).and_return fake_session
    fake_cookies = {}
    @c.stub!(:cookies).and_return fake_cookies
    @c.params = {}
    @c.request = stub(:env => {})
  end

  before do
    #controller
    @c = ActionController::Base.new
    reset!

    #locale
    FastGettext.available_locales = nil
    FastGettext.locale = I18n.default_locale = 'fr'
    FastGettext.available_locales = ['fr','en']
  end

  it "changes the locale" do
    @c.params = {:locale=>'en'}
    @c.set_gettext_locale
    @c.session[:locale].should == 'en'
    FastGettext.locale.should == 'en'
  end

  it "stays with default locale when none was found" do
    @c.set_gettext_locale
    @c.session[:locale].should == 'fr'
    FastGettext.locale.should == 'fr'
  end

  it "locale isn't cached over request" do
    @c.params = {:locale=>'en'}
    @c.set_gettext_locale
    @c.session[:locale].should == 'en'

    reset!
    @c.set_gettext_locale
    @c.session[:locale].should == 'fr'
  end

  it "reads the locale from the HTTP_ACCEPT_LANGUAGE" do
    @c.request.stub!(:env).and_return 'HTTP_ACCEPT_LANGUAGE'=>'de-de,de;q=0.8,en-us;q=0.5,en;q=0.3'
    @c.set_gettext_locale
    FastGettext.locale.should == 'en'
  end
end
