# encoding: utf-8
require "spec_helper"

class NameTest < ActiveRecord::Base
end

describe ActiveModel::Name do
  before do
    FastGettext.current_cache = {}
  end

  describe 'human' do
    it "is translated through FastGettext" do
      name = ActiveModel::Name.new(NameTest)
      name.should_receive(:_).with('Name test').and_return('Autositz')
      name.human.should == 'Autositz'
    end
  end
end
