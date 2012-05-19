# coding: utf-8
require "spec_helper"
require 'gettext_i18n_rails/model_attributes_finder'

ActiveRecord::Base.establish_connection({
  :adapter => "sqlite3",
  :database => ":memory:",
})

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
end

class Part < ActiveRecord::Base
end

class NotConventional < ActiveRecord::Base
  set_table_name :not_at_all_conventionals
end

if Rails::VERSION::MAJOR > 2
  module Test
    class Application < Rails::Application
    end
  end
end

describe GettextI18nRails::ModelAttributesFinder do
  let(:finder) { GettextI18nRails::ModelAttributesFinder.new }

  before do
    Rails.application
  end

  describe :find do
    it "returns all AR models" do
      keys = finder.find({}).keys
      if Rails::VERSION::MAJOR > 2
        keys.should == [CarSeat, NotConventional, Part]
      else
        keys.should == [CarSeat, Part]
      end
    end

    it "returns all columns for each model" do
      attributes = finder.find({})
      attributes[CarSeat].should == ['id', 'seat_color']
      attributes[NotConventional].should == ['id', 'name'] if Rails::VERSION::MAJOR > 2
      attributes[Part].should == ['car_seat_id', 'id', 'name']
    end
  end
end
