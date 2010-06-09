require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  describe "activation" do
    before(:each) do
      @user = Factory.create(:user)
      @event = @user.events.create(:category_id => 1, :design_id => 1, :name => "some name", :starting_at => 10.days.from_now)
      @event.should_not be_new_record
      @event.user_is_activated.should_not be_true
    end

    it "should set events as activated" do
      @user.activated_at Time.now.utc
      @user.save.should be_true
      @event.reload.user_is_activated.should_not be_true
    end
  end
end