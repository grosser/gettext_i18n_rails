namespace :gettext do
  def load_gettext
    require 'gettext'

    begin
      # gettext 3.0
      require 'gettext/tools'
    rescue LoadError
      # gettext <= 2.3.9
      require 'gettext/utils'
    end
  end

  desc "Create mo-files for L10n"
  task :pack => :environment do
    load_gettext

    if GetText.respond_to? :create_mofiles
      GetText.create_mofiles(true, locale_path, locale_path)
    else
      # gettext 3.0
      locale_dirs.each do |locale_dir|
        Dir.glob("#{locale_dir}/*.po").each do |po_file|
          GetText::Tools::MsgFmt.run(po_file, "--output",
            # put the MO file to LC_MESSAGES subdirectory
            File.join(File.dirname(po_file), "LC_MESSAGES", File.basename(po_file, ".po") + ".mo"))
        end
      end
    end
  end

  desc "Update pot/po files."
  task :find => :environment do
    load_gettext
    $LOAD_PATH << File.join(File.dirname(__FILE__),'..','..','lib') # needed when installed as plugin

    require "gettext_i18n_rails/haml_parser"
    require "gettext_i18n_rails/slim_parser"

    # gettext 3.0
    if defined?(GetText::Tools::XGetText)
      pot_file = File.join(locale_path, text_domain + ".pot")
      options = [ "--output", pot_file ]
      options.concat(files_to_translate)

      # create POT file
      GetText::Tools::XGetText.run(*options)

      # merge the POT file to PO files to update the translations
      locale_dirs.each do |locale_dir|
        Dir.glob("#{locale_dir}/**/#{text_domain}.po").each do |po_file|
          puts "Updating #{po_file}"
          GetText::Tools::MsgMerge.run(po_file, pot_file, "--output", po_file)
        end
      end
    elsif GetText.respond_to? :update_pofiles_org
      if defined?(Rails.application)
        msgmerge = Rails.application.config.gettext_i18n_rails.msgmerge
      end
      msgmerge ||= %w[--sort-output --no-location --no-wrap]

      GetText.update_pofiles_org(
        text_domain,
        files_to_translate,
        "version 0.0.1",
        :po_root => locale_path,
        :msgmerge => msgmerge
      )
    else #we are on a version < 2.0
      puts "install new GetText with gettext:install to gain more features..."
      #kill ar parser...
      require 'gettext/parser/active_record'
      module GetText
        module ActiveRecordParser
          module_function
          def init(x);end
        end
      end

      #parse files.. (models are simply parsed as ruby files)
      GetText.update_pofiles(
        text_domain,
        files_to_translate,
        "version 0.0.1",
        locale_path
      )
    end
  end

  # This is more of an example, ignoring
  # the columns/tables that mostly do not need translation.
  # This can also be done with GetText::ActiveRecord
  # but this crashed too often for me, and
  # IMO which column should/should-not be translated does not
  # belong into the model
  #
  # You can get your translations from GetText::ActiveRecord
  # by adding this to you gettext:find task
  #
  # require 'active_record'
  # gem "gettext_activerecord", '>=0.1.0' #download and install from github
  # require 'gettext_activerecord/parser'
  desc "write the model attributes to <locale_path>/model_attributes.rb"
  task :store_model_attributes => :environment do
    FastGettext.silence_errors

    require 'gettext_i18n_rails/model_attributes_finder'
    require 'gettext_i18n_rails/active_record'

    storage_file = "#{locale_path}/model_attributes.rb"
    puts "writing model translations to: #{storage_file}"

    ignore_tables = [/^sitemap_/, /_versions$/, 'schema_migrations', 'sessions', 'delayed_jobs']
    GettextI18nRails.store_model_attributes(
      :to => storage_file,
      :ignore_columns => [/_id$/, 'id', 'type', 'created_at', 'updated_at'],
      :ignore_tables => ignore_tables
    )
  end

  desc "add a new language"
  task :add_language, [:language] => :environment do |_, args|
    language = args.language || ENV["LANGUAGE"]

    # Let's do some pre-verification of the environment.
    if language.nil?
      puts "You need to specify the language to add. Either 'LANGUAGE=eo rake gettext:add_languange' or 'rake gettext:add_languange[eo]'"
      next
    end
    pot = File.join(locale_path, "#{text_domain}.pot")
    if !File.exists? pot
      puts "You don't have a pot file yet, you probably should run 'rake gettext:find' at least once. Tried '#{pot}'."
      next
    end

    # Create the directory for the new language.
    dir = File.join(locale_path, language)
    puts "Creating directory #{dir}"
    Dir.mkdir dir

    # Create the po file for the new language.
    new_po = File.join(locale_path, language, "#{text_domain}.po")
    puts "Initializing #{new_po} from #{pot}."
    system "msginit --locale=#{language} --input=#{pot} --output=#{new_po}"
  end

  def locale_path
    path = FastGettext.translation_repositories[text_domain].instance_variable_get(:@options)[:path] rescue nil
    path || File.join(Rails.root, "locale")
  end

  def locale_dirs
    dirs = []
    base_dir = locale_path

    Dir.open(base_dir) do |dir|
      dir.each do |entry|
        next unless /\A[a-z]{2}(?:_[A-Z]{2})?\z/ =~ entry
        next unless File.directory?(File.join(dir.path, entry))
        dirs << File.join(base_dir, entry)
      end
    end

    dirs
  end


  def text_domain
    # if your textdomain is not 'app': require the environment before calling e.g. gettext:find OR add TEXTDOMAIN=my_domain
    ENV['TEXTDOMAIN'] || (FastGettext.text_domain rescue nil) || "app"
  end

  # do not rename, gettext_i18n_rails_js overwrites this to inject coffee + js
  def files_to_translate
    Dir.glob("{app,lib,config,#{locale_path}}/**/*.{rb,erb,haml,slim}")
  end
end
