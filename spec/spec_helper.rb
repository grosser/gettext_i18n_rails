require 'active_support/version'
if RUBY_VERSION > "2" && ActiveSupport::VERSION::MAJOR == 2
  warn "Not running ruby 2 vs rails 2 tests"
  exit 0
end

require 'tempfile'
require 'active_support'
require 'active_support/core_ext/string/output_safety'
require 'active_record'
require 'action_controller'
require 'action_mailer'
require 'fast_gettext'
require 'gettext_i18n_rails'
require 'temple'

if ActiveSupport::VERSION::MAJOR >= 3
  I18n.enforce_available_locales = false # maybe true ... not sure
end

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
  config.mock_with(:rspec) { |c| c.syntax = :should }
end

begin
  Gem.all_load_paths
rescue
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

def with_file(content, extension = '')
  Tempfile.open(['gettext_i18n_rails_specs', extension]) do |f|
    f.write(content)
    f.close
    yield f.path
  end
end

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

ActiveRecord::Schema.verbose = false
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
