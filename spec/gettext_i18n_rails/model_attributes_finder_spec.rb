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
    Rails.application rescue nil
  end

  # Rails < 3.0 doesn't have DescendantsTracker.
  # Instead of iterating over ObjectSpace (slow) the decision was made NOT to support
  # class hierarchies with abstract base classes in Rails 2.x
  describe "#find" do
    it "returns all AR models" do
      keys = finder.find({}).keys
      expected = [CarSeat, Part, StiParent]
      expected.concat [AbstractParentClass, NotConventional] if Rails::VERSION::MAJOR >= 3
      expected.concat [ActiveRecord::SchemaMigration] if Rails::VERSION::MAJOR >= 4
      keys.should =~ expected
    end

    it "returns all columns for each model" do
      attributes = finder.find({})
      attributes[CarSeat].should == ['id', 'seat_color']
      attributes[NotConventional].should == ['id', 'name'] if Rails::VERSION::MAJOR > 2
      attributes[Part].should == ['car_seat_id', 'id', 'name']
      attributes[StiParent].should == ['child_attribute', 'id', 'type']
      attributes[AbstractParentClass].should ==
        ['another_child_attribute', 'child_attribute', 'id'] if Rails::VERSION::MAJOR > 2
    end
  end
end
