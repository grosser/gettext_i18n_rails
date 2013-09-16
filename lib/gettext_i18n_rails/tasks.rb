require "gettext/tools/task"

namespace :gettext do
  def locale_path
    path = FastGettext.translation_repositories[text_domain].instance_variable_get(:@options)[:path] rescue nil
    path || File.join(Rails.root, "locale")
  end

  def text_domain
    # if your textdomain is not 'app': require the environment before calling e.g. gettext:find OR add TEXTDOMAIN=my_domain
    ENV['TEXTDOMAIN'] || (FastGettext.text_domain rescue nil) || "app"
  end

  # do not rename, gettext_i18n_rails_js overwrites this to inject coffee + js
  def files_to_translate
    Dir.glob("{app,lib,config,#{locale_path}}/**/*.{rb,erb,haml,slim}")
  end

  $LOAD_PATH << File.join(File.dirname(__FILE__),'..','..','lib') # needed when installed as plugin

  require "gettext_i18n_rails/haml_parser"
  require "gettext_i18n_rails/slim_parser"

  GetText::Tools::Task.define do |task|
    task.package_name = text_domain
    task.package_version = "1.0.0"
    task.domain = text_domain
    task.po_base_directory = locale_path
    task.mo_base_directory = locale_path
    task.files = files_to_translate
    task.enable_description = false
    if defined?(Rails.application)
      msgmerge = Rails.application.config.gettext_i18n_rails.msgmerge
    end
    msgmerge ||= %w[--sort-output --no-location --no-wrap]
    task.msgmerge_options = msgmerge
  end

  desc "Create mo-files for L10n"
  task :pack => [:environment, "gettext:gettext:mo:update"] do
  end

  desc "Update pot/po files."
  task :find => [:environment, "gettext:gettext:po:update"] do
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

    language_path = File.join(locale_path, language)
    mkdir_p(language_path)
    ruby($0, "gettext:find")
  end
end
