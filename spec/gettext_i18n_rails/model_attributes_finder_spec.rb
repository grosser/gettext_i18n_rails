# coding: utf-8
require "spec_helper"
require "gettext_i18n_rails/model_attributes_finder"

module Test
  class Application < Rails::Application
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
  describe ".store_model_attributes" do
    it "emits model names as n_() plural pairs and attributes as _()" do
      FastGettext.silence_errors
      content = with_file('') do |path|
        GettextI18nRails.store_model_attributes(:to => path, :ignore_columns => [/_id$/, 'id', 'type'])
        File.read(path)
      end
      content.should include("n_('CarSeat', 'CarSeats')")
      content.should include("n_('Part', 'Parts')")
      content.should include("_('CarSeat|Seat color')")
      content.should_not include("_('CarSeat')")
    end
  end

  describe "#find" do
    it "returns all AR models" do
      keys = finder.find({}).keys
      expected = [CarSeat, Part, StiParent, AbstractParentClass, NotConventional]
      keys.should =~ expected
    end

    it "returns all columns for each model" do
      attributes = finder.find({})
      attributes[CarSeat].should == ['id', 'seat_color']
      attributes[NotConventional].should == ['id', 'name']
      attributes[Part].should == ['car_seat_id', 'id', 'name']
      attributes[StiParent].should == ['child_attribute', 'id', 'type']
      attributes[AbstractParentClass].should == ['another_child_attribute', 'child_attribute', 'id']
    end
  end
end
