# coding: utf-8
require "spec_helper"

describe ActiveRecord::Base do
  before do
    FastGettext.reload!
  end

  describe :human_name do
    it "is translated through FastGettext using the raw class name" do
      CarSeat.should_receive(:_).with('CarSeat').and_return('Autositz')
      CarSeat.human_name.should == 'Autositz'
    end
  end

  describe :gettext_model_name_msgid do
    it "uses the raw class name" do
      CarSeat.gettext_model_name_msgid.should == 'CarSeat'
    end

    it "falls back to the legacy humanized msgid and warns" do
      FastGettext.stub(:current_repository).and_return('Car seat' => 'Autositz')
      GettextI18nRails.should_receive(:warn_legacy_model_msgid).with('Car seat', 'CarSeat')
      CarSeat.gettext_model_name_msgid.should == 'Car seat'
    end
  end

  describe :human_attribute_name do
    it "translates attributes through FastGettext" do
      CarSeat.should_receive(:s_).with('CarSeat|Seat color').and_return('Sitz farbe')
      CarSeat.human_attribute_name(:seat_color).should == 'Sitz farbe'
    end

    it "translates nested attributes through FastGettext" do
      CarSeat.should_receive(:s_).with('CarSeat|Parts|Name').and_return('Handle')
      CarSeat.human_attribute_name(:"parts.name").should == 'Handle'
    end

    it "translates attributes of STI classes through FastGettext" do
      StiChild.should_receive(:s_).with('StiParent|Child attribute').and_return('Kinderattribut')
      StiChild.human_attribute_name(:child_attribute).should == 'Kinderattribut'
    end

    it "translates attributes of concrete children of abstract parent classes" do
      ConcreteChildClass.should_receive(:s_).with('AbstractParentClass|Child attribute').and_return('Kinderattribut')
      ConcreteChildClass.human_attribute_name(:child_attribute).should == 'Kinderattribut'
    end
  end

  describe :gettext_translation_for_attribute_name do
    it "translates foreign keys to the raw model name key" do
      Part.gettext_translation_for_attribute_name(:car_seat_id).should == 'CarSeat'
    end

    it "falls back to the legacy humanized foreign key msgid" do
      FastGettext.stub(:current_repository).and_return('Car seat' => 'Autositz')
      GettextI18nRails.stub(:warn_legacy_model_msgid)
      Part.gettext_translation_for_attribute_name(:car_seat_id).should == 'Car seat'
    end
  end

  describe 'error messages' do
    let(:model){
      c = CarSeat.new
      c.valid?
      c
    }

    it "translates error messages" do
      FastGettext.stub(:current_repository).and_return('translate me'=>"Übersetz mich!")
      FastGettext._('translate me').should == "Übersetz mich!"
      model.errors.full_messages.should == ["Seat color Übersetz mich!"]
    end

    it "translates scoped error messages" do
      pending 'scope is no longer added in 3.x' if ActiveRecord::VERSION::MAJOR >= 3
      FastGettext.stub(:current_repository).and_return('activerecord.errors.translate me'=>"Übersetz mich!")
      FastGettext._('activerecord.errors.translate me').should == "Übersetz mich!"
      model.errors.full_messages.should == ["Seat color Übersetz mich!"]
    end

    it "translates error messages with %{fn}" do
      pending
      FastGettext.stub(:current_repository).and_return('translate me'=>"Übersetz %{fn} mich!")
      FastGettext._('translate me').should == "Übersetz %{fn} mich!"
      model.errors[:seat_color].should == ["Übersetz car_seat mich!"]
    end
  end
end
