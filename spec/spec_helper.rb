require 'rubygems'

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))

require 'tempfile'
require 'active_support'
require 'active_record'
require 'action_controller'
require 'action_mailer'
require 'fast_gettext'
require 'gettext_i18n_rails'

begin
  Gem.all_load_paths
rescue
  puts "Fixing Gem.all_load_paths"
  module Gem;def self.all_load_paths;[];end;end
end

module Rails
  def self.root
    File.dirname(__FILE__)
  end
end

def with_file(content)
  Tempfile.open('gettext_i18n_rails_specs') do |f|
    f.write(content)
    f.close
    yield f.path
  end
end