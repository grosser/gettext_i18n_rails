require "gettext/tools/task"
gem "gettext", ">= 3.0.2"

namespace :gettext do
  def locale_path
    path = FastGettext.translation_repositories[text_domain].instance_variable_get(:@options)[:path] rescue nil
    path || File.join(Rails.root, "locale")
  end

  def text_domain
    # if your textdomain is not 'app': require the environment before calling e.g. gettext:find OR add TEXTDOMAIN=my_domain
    (FastGettext.text_domain rescue nil) || ENV['TEXTDOMAIN'] || "app"
  end

  # do not rename, gettext_i18n_rails_js overwrites this to inject coffee + js
  def files_to_translate
    Dir.glob("{app,lib,config,#{locale_path}}/**/*.{rb,erb,haml,slim}")
  end

  def gettext_default_options
    config = (Rails.application.config.gettext_i18n_rails.default_options if defined?(Rails.application))
    config || %w[--sort-by-msgid --no-location --no-wrap]
  end

  def gettext_msgmerge_options
    config = (Rails.application.config.gettext_i18n_rails.msgmerge if defined?(Rails.application))
    config || gettext_default_options
  end

  def gettext_msgcat_options
    config = (Rails.application.config.gettext_i18n_rails.msgcat if defined?(Rails.application))
    config || gettext_default_options
  end

  def gettext_xgettext_options
    config = (Rails.application.config.gettext_i18n_rails.xgettext if defined?(Rails.application))
    config || gettext_default_options
  end

  require "gettext_i18n_rails/haml_parser"
  require "gettext_i18n_rails/slim_parser"

  task :setup => [:environment] do
    GetText::Tools::Task.define do |task|
      task.package_name = text_domain
      task.package_version = "1.0.0"
      task.domain = text_domain
      task.po_base_directory = locale_path
      task.mo_base_directory = locale_path
      task.files = files_to_translate
      task.enable_description = false
      task.msgmerge_options = gettext_msgmerge_options
      task.msgcat_options = gettext_msgcat_options
      task.xgettext_options = gettext_xgettext_options
    end
  end

  desc "Create mo-files"
  task :pack => [:setup] do
    Rake::Task["gettext:mo:update"].invoke
  end

  desc "Update pot/po files"
  task :find => [:setup] do
    Rake::Task["gettext:po:update"].invoke
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

    GettextI18nRails.store_model_attributes(
      :to => storage_file,
      :ignore_columns => [/_id$/, 'id', 'type', 'created_at', 'updated_at'],
      :ignore_tables => GettextI18nRails::IGNORE_TABLES
    )
  end

  desc "add a new language"
  task :add_language, [:language] => :environment do |_, args|
    language = args.language || ENV["LANGUAGE"]

    # Let's do some pre-verification of the environment.
    if language.nil?
      puts "You need to specify the language to add. Either 'LANGUAGE=eo rake gettext:add_language' or 'rake gettext:add_language[eo]'"
      next
    end

    language_path = File.join(locale_path, language)
    mkdir_p(language_path)
    Rake.application.lookup('gettext:find', _.scope).invoke
  end
end
