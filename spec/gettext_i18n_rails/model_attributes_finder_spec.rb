# coding: utf-8
require "spec_helper"
require File.expand_path(File.dirname(__FILE__) + '../../../lib/gettext_i18n_rails/model_attributes_finder')

#FastGettext.silence_errors

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
end

#ActiveRecord::Base.extend GettextI18nRails::ActiveRecord

class CarSeat < ActiveRecord::Base
end

class Part < ActiveRecord::Base
end

describe GettextI18nRails::ModelAttributesFinder do
  let(:finder) { GettextI18nRails::ModelAttributesFinder.new }

  describe :find do
    it "returns all AR models" do
      finder.find({}).keys.should == [CarSeat, Part]
    end

    it "returns all columns for each model" do
      attributes = finder.find({})
      attributes[CarSeat].should == ['id', 'seat_color']
      attributes[Part].should == ['car_seat_id', 'id', 'name']
    end
  end
end
