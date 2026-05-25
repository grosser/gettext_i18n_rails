# encoding: utf-8
require "spec_helper"

if ActiveRecord::VERSION::MAJOR >= 3
  require "gettext_i18n_rails/active_model/name"

  describe ActiveModel::Name do
    before do
      FastGettext.reload!
    end

    describe '#human' do
      it "is translated through FastGettext using the raw class name" do
        name = ActiveModel::Name.new(CarSeat)
        name.should_receive(:_).with('CarSeat').and_return('Autositz')
        name.human.should == 'Autositz'
      end

      it "is translated through FastGettext in plural form" do
        name = ActiveModel::Name.new(CarSeat)
        name.should_receive(:n_).with('CarSeat', 'CarSeats', 2).and_return('Сиденья')
        name.human(count: 2).should == 'Сиденья'
      end

      it "falls back to the legacy humanized msgid" do
        FastGettext.stub(:current_repository).and_return('Car seat' => 'Autositz')
        GettextI18nRails.stub(:warn_legacy_model_msgid)
        ActiveModel::Name.new(CarSeat).human.should == 'Autositz'
      end
    end
  end
end
