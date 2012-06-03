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

  module VERSION
    MAJOR = 3
    MINOR = 1
    PATCH = 0
    STRING = "#{MAJOR}.#{MINOR}.#{PATCH}"
  end
end

def with_file(content)
  Tempfile.open('gettext_i18n_rails_specs') do |f|
    f.write(content)
    f.close
    yield f.path
  end
end

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

ActiveRecord::Schema.define(:version => 1) do
  create_table :car_seats, :force=>true do |t|
    t.string :seat_color
  end

  create_table :parts, :force=>true do |t|
    t.string :name
    t.references :car_seat
  end

  create_table :not_at_all_conventionals, :force=>true do |t|
    t.string :name
  end
end

class CarSeat < ActiveRecord::Base
  validates_presence_of :seat_color, :message=>"translate me"
  has_many :parts
  accepts_nested_attributes_for :parts
end

class Part < ActiveRecord::Base
  belongs_to :car_seat
end

class NotConventional < ActiveRecord::Base
  set_table_name :not_at_all_conventionals
end

class Idea < ActiveRecord::Base
  self.abstract_class = true
end

ActiveRecord::Base.extend GettextI18nRails::ActiveRecord
