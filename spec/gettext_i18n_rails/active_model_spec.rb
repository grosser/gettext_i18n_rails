# encoding: utf-8
require "spec_helper"

describe ActiveModel::Name do
  before do
    FastGettext.current_cache = {}
  end

  describe 'human' do
    it "is translated through FastGettext" do
      name = ActiveModel::Name.new(CarSeat)
      name.should_receive(:_).with('Car seat').and_return('Autositz')
      name.human.should == 'Autositz'
    end
  end
end
