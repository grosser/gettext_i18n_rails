require File.expand_path("../spec_helper", File.dirname(__FILE__))

FastGettext.silence_errors

class CarSeat < ActiveRecord::Base
end

describe ActiveRecord::Base do
  it "has a human name that is translated through FastGettext" do
    CarSeat.expects(:_).with('car seat').returns('Autositz')
    CarSeat.human_name.should == 'Autositz'
  end
  it "translates attributes through FastGettext" do
    CarSeat.expects(:s_).with('CarSeat|Seat color').returns('Sitz farbe')
    CarSeat.human_attribute_name(:seat_color).should == 'Sitz farbe'
  end
end