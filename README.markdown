Simple [FastGettext](http://github.com/grosser/fast_gettext) / Rails integration.

The idea is simple: use Rails I18n::Simple for all default translations,  
and do our own translations with FastGettext!

Rails does: `I18n.t('weir.rails.syntax.i.hate')`  
We do: `_('Just translate my damn text!')`

[See it working in the example application.](https://github.com/grosser/gettext_i18n_rails_example)

Setup
=====
###Installation
This plugin:
    ./script/plugin install git://github.com/grosser/gettext_i18n_rails.git
[FastGettext](http://github.com/grosser/fast_gettext):
    sudo gem install grosser-fast_gettext -s http://gems.github.com/
[GetText 2.0](http://github.com/mutoh/gettext):
    rake gettext:install

### Locales & initialisation
Copy default locales you want from e.g. http://github.com/svenfuchs/rails-i18n/rails/locale/de.yml  
into 'config/locales'

    #environment.rb
    Rails::Initializer.run do |config|
      ...
      config.gem "grosser-fast_gettext", :lib => 'fast_gettext', :version => '0.2.9', :source=>"http://gems.github.com/"
    end
    FastGettext.add_text_domain 'app', :path => File.join(RAILS_ROOT, 'locale')

    #application_controller
    class ApplicationController < ...
      before_filter :set_gettext_locale
      def set_gettext_locale
        FastGettext.text_domain = 'app'
        FastGettext.available_locales = ['en','de'] #all you want to allow
        super
      end

Translating
===========
 - use some _('translations')
 - run `rake gettext:find`, to let GetText find all translations used
 - if this is your first translation: `cp locale/app.pot locale/de/app.po` for every locale you want to use
 - translate messages in 'locale/de/app.po' (leave msgstr blank and msgstr == msgid)  
new translations will be marked "fuzzy", search for this and remove it, so that they will be used.
Obsolete translations are marked with ~#, they usually can be removed since they are no longer needed
 - run `rake gettext:pack` to write GetText format translation files

Namespaces
==========
Car|Model means Model in namespace Car.  
You do not have to translate this into english "Model", if you use the
namespace-aware translation
    s_('Car|Model') == 'Model' #when no translation was found

Plurals
=======
GetText supports pluralization
    n_('Apple','Apples',3) == 'Apples'

Unfound translations
====================
Sometimes GetText cannot find a translation like `_("x"+"u")`,  
for this cases either add `N_('xu')` somewhere else in the code,  
where it can be seen by GetText, or even in a totally seperate file like  
`locale/unfound_translations.rb`, or use the [gettext_test_log rails plugin ](http://github.com/grosser/gettext_test_log)
to find all translations that where used while testing.  

Author
======
GetText -> Masao Mutoh, from whom i learned how the internals work :)
FastGettext -> Me

Michael Grosser  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...  
