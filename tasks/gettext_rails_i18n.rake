namespace :gettext do
  desc "Create mo-files for L10n"
  task :pack do
    require 'gettext/utils'
    GetText.create_mofiles(true, "locale", "locale")
  end

  desc "Update pot/po files."
  task :find => :environment do
    gem "gettext_activerecord", '>=0.1.0' #download and install from github
    require 'gettext'
    require 'gettext_activerecord/parser'
    require 'gettext/utils'
    GetText.update_pofiles(
      "app",
      Dir.glob("{app,lib,config}/**/*.{rb,erb}"),
      "version 0.0.1",
      "locale",
      "locale/tmp.pot"
    )
  end
end