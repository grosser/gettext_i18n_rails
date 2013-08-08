require 'rubygems'

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))

require 'tempfile'
require 'active_support'
require 'active_record'
require 'action_controller'
require 'action_mailer'
require 'fast_gettext'
require 'gettext_i18n_rails'
require 'temple'

begin
  Gem.all_load_paths
rescue
  puts "Fixing Gem.all_load_paths"
  module Gem;def self.all_load_paths;[];end;end
end


# make temple not blow up in rails 2 env
class << Temple::Templates
  alias_method :method_missing_old, :method_missing
  def method_missing(name, engine, options = {})
    name == :Rails || method_missing_old(name, engine, options)
  end
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

  create_table :sti_parents, :force => true do |t|
    t.string :type
    t.string :child_attribute
  end

  create_table :concrete_child_classes, :force => true do |t|
    t.string :child_attribute
  end

  create_table :other_concrete_child_classes, :force => true do |t|
    t.string :another_child_attribute
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

class StiParent < ActiveRecord::Base; end
class StiChild < StiParent; end

class AbstractParentClass < ActiveRecord::Base
  self.abstract_class = true
end
class ConcreteChildClass < AbstractParentClass; end
class OtherConcreteChildClass < AbstractParentClass; end

class NotConventional < ActiveRecord::Base
  if ActiveRecord::VERSION::MAJOR == 2
    set_table_name :not_at_all_conventionals
  else
    self.table_name = :not_at_all_conventionals
  end
end

class Idea < ActiveRecord::Base
  self.abstract_class = true
end
