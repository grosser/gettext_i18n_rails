Simple [FastGettext](http://github.com/grosser/fast_gettext) / Rails integration.

The idea is simple: use Rails I18n::Simple for all default translations,  
and do our own translations with FastGettext!

Rails does: `I18n.t('weir.rails.syntax.i.hate')`  
We do: `_('Just translate my damn text!')`

Setup
=====
We need the new gettext for message parsing, it has to be installed by `rake gem && sudo gem install pkg/*`

 - install [gettext 2.0](http://github.com/mutoh/gettext)
 - install [gettext_activerecord 0.1](http://github.com/mutoh/gettext)

And we need [FastGettext  0.2.4](http://github.com/grosser/fast_gettext) for translation.
    sudo gem install grosser-fast_gettext -s http://gems.github.com/

then:
Copy default locales you want from e.g. http://github.com/svenfuchs/rails-i18n/rails/locale/de.yml  
into config/locales

Create a folder for each locale you want to use e.g. `locale/en`

    #environment.rb
    Rails::Initializer.run do |config|
      ...
      config.gem "grosser-fast_gettext", :lib => 'fast_gettext', :version => '0.2.1', :source=>"http://gems.github.com/"
    end
    FastGettext.add_text_domain 'app', :path => File.join(RAILS_ROOT, 'locale')

    #application_controller
    FastGettext.text_domain= 'app'
    FastGettext.available_locales = ['en','de']
    class ApplicationController < ...
      include FastGettext

      before_filter :set_gettext_locale
      def set_gettext_locale
        FastGettext.text_domain= 'app'
        FastGettext.available_locales = ['en','de']
        super
      end

    #application_helper
    module ApplicationHelper
      include FastGettext

Translating
===========
 - use some _('translations')
 - run `rake gettext:find`, to let GetText find all translations used
 - if this is your first translation: `cp locale/app.pot locale/de/app.po` for every locale you want to use
 - translate messages in 'locale/de/app.po' (leave msgstr blank and msgstr == msgid)  
new translations will be mared "fuzzy", search for this and remove it, so that they will be used
obsolete translations are marked with ~#, they usually can be removed since they are no longer needed  
 - run `rake gettext:pack` to write GetText format translation files

Namespaces
==========
Car|Model means Model in namespace Car.  
You do not have to translate this into english "Model", if you use the
namespace-aware translation
    s_('Car|Model') == 'Model'#when no translation was found

Plurals
=======
GetText supports pluralization
    n_('Apple','Apples',3) == 'Apples'

Unfound translations
====================
Sometimes GetText cannot find a translation like `_("x"+"u")`,  
for this cases either add `N_('xu')` somewhere else in the code,  
where it can be seen by GetText, or even in a totally seperate file like  
`unfound_translations.rb`, or use the [gettext_test_log rails plugin ](http://github.com/grosser/gettext_test_log)  
to find all translations that where used while testing.  

###Improving Rails translations
You certanly want to add at least:
    #de.yml
    active_record:
      models:
        car: 'Auto'
        ...
So that error messages use the translated version of your model.
Further help can be found [here](http://iain.nl/2008/09/translating-activerecord)

Author
======
GetText -> Masao Mutoh, from whom i learned how the internals work :)
FastGettext -> Me

Michael Grosser  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...  
