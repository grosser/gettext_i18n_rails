# encoding: UTF-8
require "spec_helper"

FastGettext.silence_errors

describe GettextI18nRails::Backend do
  it "redirects calls to another I18n backend" do
    subject.backend.should_receive(:xxx).with(1,2)
    subject.xxx(1,2)
  end

  describe :available_locales do
    it "maps them to FastGettext" do
      FastGettext.should_receive(:available_locales).and_return [:xxx]
      subject.available_locales.should == [:xxx]
    end

    it "and returns an empty array when FastGettext.available_locales is nil" do
      FastGettext.should_receive(:available_locales).and_return nil
      subject.available_locales.should == []
    end
  end

  describe :translate do
    it "uses gettext when the key is translatable" do
      FastGettext.stub(:current_repository).and_return 'xy.z.u'=>'a'
      subject.translate('xx','u',:scope=>['xy','z']).should == 'a'
    end

    it "interpolates options" do
      FastGettext.stub(:current_repository).and_return 'ab.c'=>'a%{a}b'
      subject.translate('xx','c',:scope=>['ab'], :a => 'X').should == 'aXb'
    end

    it "will not try and interpolate when there are no options given" do
      result = 'aXb'
      result.should_receive(:%).never
      FastGettext.stub(:current_repository).and_return 'ab.c' => result
      subject.translate('xx','c', :scope=>['ab']).should == 'aXb'
    end

    it "can translate with gettext using symbols" do
      FastGettext.stub(:current_repository).and_return 'xy.z.v'=>'a'
      subject.translate('xx',:v ,:scope=>['xy','z']).should == 'a'
    end

    it "can translate with gettext using a flat scope" do
      FastGettext.stub(:current_repository).and_return 'xy.z.x'=>'a'
      subject.translate('xx',:x ,:scope=>'xy.z').should == 'a'
    end

    it "passes non-gettext keys to default backend" do
      subject.backend.should_receive(:translate).with('xx', 'c', {}).and_return 'd'
      FastGettext.stub(:current_repository).and_return 'a'=>'b'
      subject.translate('xx', 'c', {}).should == 'd'
    end

    if RUBY_VERSION > "1.9"
      it "produces UTF-8 when not using FastGettext to fix weird encoding bug" do
        subject.backend.should_receive(:translate).with('xx', 'c', {}).and_return 'ü'.force_encoding("US-ASCII")
        FastGettext.stub(:current_repository).and_return 'a'=>'b'
        result = subject.translate('xx', 'c', {})
        result.should == 'ü'
      end

      it "does not force_encoding on non-strings" do
        subject.backend.should_receive(:translate).with('xx', 'c', {}).and_return ['aa']
        FastGettext.stub(:current_repository).and_return 'a'=>'b'
        result = subject.translate('xx', 'c', {})
        result.should == ['aa']
      end
    end

    # TODO NameError is raised <-> wtf ?
    xit "uses the super when the key is not translatable" do
      lambda{subject.translate('xx','y',:scope=>['xy','z'])}.should raise_error(I18n::MissingTranslationData)
    end
  end

  describe :interpolate do
    it "act as an identity function for an array" do
      translation = [:month, :day, :year]
      subject.send(:interpolate, translation, {}).should == translation
    end
  end
end
