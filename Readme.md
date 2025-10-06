[FastGettext](http://github.com/grosser/fast_gettext) / Rails integration.

Translate via FastGettext, use any other I18n backend as extension/fallback.

Rails does: `I18n.t('syntax.with.lots.of.dots')` with nested yml files
We do: `_('Just translate my damn text!')` with simple, flat mo/po/yml files or directly from db
To use I18n calls add a `syntax.with.lots.of.dots` translation.

[See it working in the example application.](https://github.com/grosser/gettext_i18n_rails_example)

Setup
=====
### Installation

```Ruby
# Gemfile
gem 'gettext_i18n_rails'
```

##### Optional:
Add `gettext` if you want to find translations or build .mo files<br/>

```Ruby
# Gemfile
gem 'gettext', '>=3.0.2', :require => false
```

###### Add first language:
Add the first language using:

```Bash
rake gettext:add_language[xx]
```

or

```Bash
LANGUAGE=xx rake gettext:add_language
```

where `xx` is the lowercased [ISO 639-1](http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) 2-letter code for the language you want to create.

for example:

```Bash
rake gettext:add_language[es]
```


This will also create the `locales` directory (where the translations are being stored) and run `gettext:find` to find any strings marked for translation.

You can, of course, add more languages using the same command.

### Locales & initialisation
Copy default locales with dates/sentence-connectors/AR-errors you want from e.g.
[rails i18n](https://github.com/svenfuchs/rails-i18n/tree/master/rails/locale/) into 'config/locales'

To initialize:

```Ruby
# config/initializers/fast_gettext.rb
FastGettext.add_text_domain 'app', :path => 'locale', :type => :po
FastGettext.default_available_locales = ['en','de'] #all you want to allow
FastGettext.default_text_domain = 'app'
```

And in your application:

```Ruby
# app/controllers/application_controller.rb
class ApplicationController < ...
  before_action :set_gettext_locale
```

Translating
===========
Performance is almost the same for all backends since translations are cached after first use.

### Option A: .po files

```Ruby
FastGettext.add_text_domain 'app', :path => 'locale', :type => :po
```

 - use some `_('translations')`
 - run `rake gettext:find`, to let GetText find all translations used
 - (optional) run `rake gettext:store_model_attributes`, to parse the database for columns that can be translated
 - if this is your first translation: `cp locale/app.pot locale/de/app.po` for every locale you want to use
 - translate messages in 'locale/de/app.po' (leave msgstr blank and msgstr == msgid)

New translations will be marked "fuzzy", search for this and remove it, so that they will be used.
Obsolete translations are marked with ~#, they usually can be removed since they are no longer needed

#### Unfound translations with rake gettext:find
Dynamic translations like `_("x"+"u")` cannot be found. You have 4 options:

 - add `N_('xu')` somewhere else in the code, so the parser sees it
 - add `N_('xu')` in a totally separate file like `locale/unfound_translations.rb`, so the parser sees it
 - use the [gettext_test_log rails plugin ](http://github.com/grosser/gettext_test_log) to find all translations that where used while testing
 - add a Logger to a translation Chain, so every unfound translations is logged ([example](http://github.com/grosser/fast_gettext))

### Option B: Traditional .po/.mo files

    FastGettext.add_text_domain 'app', :path => 'locale'

 - follow Option A
 - run `rake gettext:pack` to write binary GetText .mo files

### Option C: Database
Most scalable method, all translators can work simultaneously and online.

Easiest to use with the [translation database Rails engine](http://github.com/grosser/translation_db_engine).
Translations can be edited under `/translation_keys`

```Ruby
FastGettext::TranslationRepository::Db.require_models
FastGettext.add_text_domain 'app', :type => :db, :model => TranslationKey
```

I18n
====

```Ruby
I18n.locale <==> FastGettext.locale.to_sym
I18n.locale = :de <==> FastGettext.locale = 'de'
```

Any call to I18n that matches a gettext key will be translated through FastGettext.

Namespaces
==========
Car|Model means Model in namespace Car.
You do not have to translate this into english "Model", if you use the
namespace-aware translation

```Ruby
s_('Car|Model') == 'Model' #when no translation was found
```

XSS / html_safe
===============
If you trust your translators and all your usages of % on translations:<br/>

```Ruby
# config/environment.rb
GettextI18nRails.translations_are_html_safe = true
```

String % vs html_safe is buggy<br/>
My recommended fix is: `require 'gettext_i18n_rails/string_interpolate_fix'`

 - safe stays safe (escape added strings)
 - unsafe stays unsafe (do not escape added strings)

ActiveRecord - error messages
=============================
ActiveRecord error messages are translated through Rails::I18n, but
model names and model attributes are translated through FastGettext.
Therefore a validation error on a BigCar's wheels_size needs `_('big car')` and `_('BigCar|Wheels size')`
to display localized.

The model/attribute translations can be found through `rake gettext:store_model_attributes`,
(which ignores some commonly untranslated columns like id,type,xxx_count,...).

Error messages can be translated through FastGettext, if the ':message' is a translation-id or the matching Rails I18n key is translated.

#### Option A:
Define a translation for "I need my rating!" and use it as message.

```Ruby
validates_inclusion_of :rating, :in=>1..5, :message=>N_('I need my rating!')
```

#### Option B:

```Ruby
validates_inclusion_of :rating, :in=>1..5
```
Make a translation for the I18n key: `activerecord.errors.models.rating.attributes.rating.inclusion`

#### Option C:
Add a translation to each config/locales/*.yml files
```Yaml
en:
  activerecord:
    errors:
      models:
        rating:
          attributes:
            rating:
              inclusion: " -- please choose!"
```
The [rails I18n guide](http://guides.rubyonrails.org/i18n.html) can help with Option B and C.

Plurals
=======
FastGettext supports pluralization
```Ruby
n_('Apple','Apples',3) == 'Apples'
```

Languages with complex plural forms (such as Polish with its 4 different forms) can also be addressed, see [FastGettext Readme](http://github.com/grosser/fast_gettext)

Customizing list of translatable files
======================================
When you run

```Bash
rake gettext:find
```

by default the following files are going to be scanned for translations: {app,lib,config,locale}/**/*.{rb,erb,haml,slim}. If
you want to specify a different list, you can redefine files_to_translate in the gettext namespace in a file like
lib/tasks/gettext.rake:

```Ruby
namespace :gettext do
  def files_to_translate
    Dir.glob("{app,lib,config,locale}/**/*.{rb,erb,haml,slim,rhtml}")
  end
end
```

Customizing text domains setup task
===================================

By default a single application text domain is created (named `app` or if you load the environment the value of `FastGettext.text_domain` is being used).

If you want to have multiple text domains or change the definition of the text domains in any way, you can do so by overriding the `:setup` task in a file like lib/tasks/gettext.rake:

```Ruby
# Remove the provided gettext setup task
Rake::Task["gettext:setup"].clear

namespace :gettext do
  task :setup => [:environment] do
    domains = Application.config.gettext["domains"]

    domains.each do |domain, options|
      files = Dir.glob(options["paths"])

      GetText::Tools::Task.define do |task|
        task.package_name = options["name"]
        task.package_version = "1.0.0"
        task.domain = options["name"]
        task.po_base_directory = locale_path
        task.mo_base_directory = locale_path
        task.files = files
        task.enable_description = false
        task.msgmerge_options = gettext_msgmerge_options
        task.msgcat_options = gettext_msgcat_options
        task.xgettext_options = gettext_xgettext_options
      end
    end
  end
end
```

Changing msgmerge, msgcat, and xgettext options
===============================================

The default options for parsing and create `.po` files are:

```Bash
--sort-by-msgid --no-location --no-wrap
```

These options sort the translations by the msgid (original / source string), don't add location information in the po file and don't wrap long message lines into several lines.

If you want to override them you can put the following into an initializer like config/initializers/gettext.rb:

```Ruby
Rails.application.config.gettext_i18n_rails.msgmerge = %w[--no-location]
Rails.application.config.gettext_i18n_rails.msgcat = %w[--no-location]
Rails.application.config.gettext_i18n_rails.xgettext = %w[--no-location]
```

or

```Ruby
Rails.application.config.gettext_i18n_rails.default_options = %w[--no-location]
```

to override both.

You can see the available options by running `rgettext -h`, `rmsgcat -f` and `rxgettext -h`.

Use I18n instead Gettext to ActiveRecord/ActiveModel translations
=================================================================

If you want to disable translations to model name and attributes you can put the following into an initializer like config/initializers/gettext.rb:

```Ruby
Rails.application.config.gettext_i18n_rails.use_for_active_record_attributes = false
```

And now you can use your I18n yaml files instead.

Auto-reload translations in development
========================================

By default, .po and .mo files are automatically reloaded in development mode when they change, so you don't need to restart the Rails server after editing translations.

This feature is enabled by default. If you want to disable it, add the following to `config/environments/development.rb`:

```Ruby
config.gettext_i18n_rails.auto_reload_in_development = false
```

The auto-reload feature uses `ActiveSupport::FileUpdateChecker` to monitor changes to translation files in your `locale/` directory and reloads them only when they've been modified, ensuring minimal performance impact.

Using your translations from javascript
=======================================

If want to use your .PO files on client side javascript you should have a look at the [GettextI18nRailsJs](https://github.com/nubis/gettext_i18n_rails_js) extension.

[Contributors](http://github.com/grosser/gettext_i18n_rails/contributors)
======
 - [ruby gettext extractor](http://github.com/retoo/ruby_gettext_extractor/tree/master) from [retoo](http://github.com/retoo)
 - [Paul McMahon](http://github.com/pwim)
 - [Duncan Mac-Vicar P](http://duncan.mac-vicar.com/blog)
 - [Ramihajamalala Hery](http://my.rails-royce.org)
 - [J. Pablo Fernández](http://pupeno.com)
 - [Anh Hai Trinh](http://blog.onideas.ws)
 - [ed0h](http://github.com/ed0h)
 - [Nikos Dimitrakopoulos](http://blog.nikosd.com)
 - [Ben Tucker](http://btucker.net/)
 - [Kamil Śliwak](https://github.com/cameel)
 - [Rainux Luo](https://github.com/rainux)
 - [Lucas Hills](https://github.com/2potatocakes)
 - [Ladislav Slezák](https://github.com/lslezak)
 - [Greg Weber](https://github.com/gregwebs)
 - [Sean Kirby](https://github.com/sskirby)
 - [Julien Letessier](https://github.com/mezis)
 - [Seb Bacon](https://github.com/sebbacon)
 - [Ramón Cahenzli](https://github.com/psy-q)
 - [rustygeldmacher](https://github.com/rustygeldmacher)
 - [Jeroen Knoops](https://github.com/JeroenKnoops)
 - [Ivan Necas](https://github.com/iNecas)
 - [Andrey Chernih](https://github.com/AndreyChernyh)
 - [Imre Farkas](https://github.com/ifarkas)
 - [Trong Tran](https://github.com/trongrg)
 - [Dmitri Dolguikh](https://github.com/witlessbird)
 - [Joe Ferris](https://github.com/jferris)
 - [exAspArk](https://github.com/exAspArk)
 - [martinpovolny](https://github.com/martinpovolny)
 - [akimd](https://github.com/akimd)
 - [adam-h](https://github.com/adam-h)

[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/grosser/gettext_i18n_rails.png)](https://travis-ci.org/grosser/gettext_i18n_rails)
