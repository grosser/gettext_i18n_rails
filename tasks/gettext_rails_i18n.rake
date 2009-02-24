namespace :gettext do
  def load_gettext
    gem 'gettext', '>=2.0.0'
    require 'gettext'
    require 'gettext/utils'
  end

  desc "Create mo-files for L10n"
  task :pack do
    load_gettext
    GetText.create_mofiles(true, "locale", "locale")
  end

  desc "Update pot/po files."
  task :find do
    load_gettext

    require 'activerecord'
    gem "gettext_activerecord", '>=0.1.0' #download and install from github
    require 'gettext_activerecord/parser'

    GetText.update_pofiles_org(
      "app",
      Dir.glob("{app,lib,config,locale}/**/*.{rb,erb}"),
      "version 0.0.1",
      :po_root => 'locale',
      :msgmerge=>['--sort-output']
    )
  end

  desc 'tries to install gettext & gettext_activerecord from git'
  task :install do
    [
      ['gettext','2.0.0'],
      ['gettext_activerecord','0.1']
    ].each do |lib,version|
      begin
        gem lib, ">=#{version}"
        puts "#{lib} version >=#{version} exists!"
      rescue LoadError
        puts "installing #{lib}...."
        raise "a folder named #{lib} already exists, aborting!!" if File.exist?(lib)
        `git clone git://github.com/mutoh/#{lib}.git`
        `cd #{lib} && rake gem`
        `sudo gem install #{lib}/pkg/#{lib}*.gem`
        `rm -rf #{lib}`
      end
    end
  end
end