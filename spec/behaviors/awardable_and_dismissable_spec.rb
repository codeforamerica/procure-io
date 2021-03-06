require_relative '../support/no_rails_tests'
require_relative '../../lib/behaviors/awardable_and_dismissable'

class NoRailsTests::AwardableAndDismissableModel < NoRailsTests::FakeModel
  include Behaviors::AwardableAndDismissable
end

describe Behaviors::AwardableAndDismissable do

  before do
    @model = NoRailsTests::AwardableAndDismissableModel.new
    stub_const("I18n", OpenStruct.new)
  end

  describe '#dismiss' do
    it 'should return false if it is already dismissed' do
      @model.dismissed_at = Time.now
      @model.dismiss(mock("Officer")).should == false
    end

    it 'should properly function if it is not already dismissed' do
      @model.should_receive(:dismissed_at=)
      @model.should_receive(:dismisser_id=).with(999)
      @model.dismiss(mock("Officer", id: 999))
    end

    it 'should call the after function if it is defined' do
      @model.should_receive(:respond_to?).at_least(:once).and_return(true)
      @model.should_receive(:after_dismiss)
      @model.dismiss(mock("Officer", id: 999))
    end

    it 'should call the after function if it is not defined' do
      @model.should_receive(:respond_to?).at_least(:once).and_return(false)
      @model.should_not_receive(:after_dismiss)
      @model.dismiss(mock("Officer", id: 999))
    end
  end

  describe '#award' do
    it 'should return false if it is already awarded' do
      @model.awarded_at = Time.now
      @model.award(mock("Officer")).should == false
    end

    it 'should properly function if it is not already awarded' do
      @model.should_receive(:awarded_at=)
      @model.should_receive(:awarder_id=).with(999)
      @model.award(mock("Officer", id: 999))
    end
  end

  describe '#undismiss' do
    it 'should return false if it is not dismissed' do
      @model.dismissed_at = nil
      @model.undismiss(mock("Officer")).should == false
    end

    it 'should properly function if it is already dismissed' do
      @model.dismissed_at = Time.now
      @model.should_receive(:dismissed_at=).with(nil)
      @model.should_receive(:dismisser_id=).with(nil)
      @model.undismiss(mock("Officer", id: 999))
    end
  end

  describe '#unaward' do
    it 'should return false if it is not awarded' do
      @model.awarded_at = nil
      @model.unaward(mock("Officer")).should == false
    end

    it 'should properly function if it is already dismissed' do
      @model.awarded_at = Time.now
      @model.should_receive(:awarded_at=).with(nil)
      @model.should_receive(:awarder_id=).with(nil)
      @model.unaward(mock("Officer", id: 999))
    end
  end

  describe '#dismissed' do
    it 'should return true when dismissed_at exists' do
      @model.dismissed_at = Time.now
      @model.dismissed.should == true
    end

    it 'should return false when dismissed_at doesnt exist' do
      @model.dismissed_at = nil
      @model.dismissed.should == false
    end
  end

  describe '#awarded' do
    it 'should return true when awarded_at exists' do
      @model.awarded_at = Time.now
      @model.awarded.should == true
    end

    it 'should return false when awarded_at doesnt exist' do
      @model.awarded_at = nil
      @model.awarded.should == false
    end
  end

  describe '#awarded_dismissed_or_open_text_status' do
    it 'should return the proper status when dismissed' do
      I18n.should_receive(:t).with("g.dismissed")
      @model.awarded_at = Time.now
      @model.dismissed_at = Time.now
      @model.awarded_dismissed_or_open_text_status
    end

    it 'should return the proper status when awarded' do
      I18n.should_receive(:t).with("g.awarded")
      @model.dismissed_at = nil
      @model.awarded_at = Time.now
      @model.awarded_dismissed_or_open_text_status
    end

    it 'should return the proper status when open' do
      I18n.should_receive(:t).with("g.open")
      @model.dismissed_at = nil
      @model.awarded_at = nil
      @model.awarded_dismissed_or_open_text_status
    end
  end

end
