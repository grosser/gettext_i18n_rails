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

then:
Copy default locales you want from e.g. http://github.com/svenfuchs/rails-i18n/rails/locale/de.yml  
into config/locales

Create a folder for each locale you want to use e.g. `locale/en`

    #environment.rb
    Rails::Initializer.run do |config|
      ...
      config.gem "gettext", :version => '2.0.0', :lib => 'gettext', :source=>"download and install from github"
    end
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
    ns_('Fruit|Apple','Fruit|Apples',1) == 'Apple' #when no translation was found

Unfound translations
====================
Sometimes GetText cannot find a translation like `_("x"+"u")`,  
for this cases either add `N_('xu')` somewhere else in the code,  
where it can be seen by GetText, or even in a totally seperate file like  
`unfound_translations.rb`, or use the [gettext_test_log rails plugin ](http://github.com/grosser/gettext_test_log)  
to find all translations that where used while testing.  

Author
======
GetText -> Masao Mutoh, from whom i learned how the internals work :)

Michael Grosser  
grosser.michael@gmail.com  
Hereby placed under public domain, do what you want, just do not hold me accountable...  
