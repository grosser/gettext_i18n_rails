Simple Gettext/Rails integration that is somewhat-**threadsafe** and **fast**!

This contains a lot of monkey-patching,  
since GetText normaly does lots of wacky/costly things,
that are not needed for simple applications.

The idea is simple: use Rails I18n::Simple for all default translations,  
and do our own translations with GetText!

Rails does: `I18n.t('weir.rails.syntax.i.hate')`  
We do: `_('Just translate my damn text!')`

Setup
=====
We need the new gettext, it has to be installed by `rake gem && sudo gem install pkg/*`
 - install [gettext 2.0](http://github.com/mutoh/gettext)
 - install [gettext_activerecord 0.1](http://github.com/mutoh/gettext) (only needed for parsing)

    Copy default locales you want from e.g. http://github.com/svenfuchs/rails-i18n/rails/locale/de.yml
    into config/locales

    Create a folder for each locale you want to use e.g. `locale/en`

    #environment.rb
    GetText.bindtextdomain 'app', :path => File.join(RAILS_ROOT, 'locale')
    GetText.available_locales = ['en','de']

    #application_controller
    include GetText
    before_filter :set_locale

    #application_helper
    include GetText

Translating
===========
 - use some _('translations')
 - run `rake gettext:find`, to let GetText find all translations used
 - `cp locale/app.pot locale/de/app.po` for every locale you want to use
 - translate messages in 'locale/de/app.po' (leave msgstr blank and msgstr == msgid)
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
    ns_('Fruit|Apple','Fruit|Apples',1) == 'Apple' #when no translation was found