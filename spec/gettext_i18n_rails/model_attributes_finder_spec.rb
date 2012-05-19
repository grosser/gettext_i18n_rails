# coding: utf-8
require "spec_helper"
require "gettext_i18n_rails/model_attributes_finder"

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
