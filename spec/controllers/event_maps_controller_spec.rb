require File.dirname(__FILE__) + '/../spec_helper'

describe EventMapsController do
  setup :activate_authlogic

  describe "not logged in user" do
    describe_action(:destroy) do
      before(:each) do
        @params = {:event_id => 1}
      end
      it_should_require_login
    end
  end

  describe "user" do
    it "should remove map" do
      @user = Factory.create(:active_user)
      UserSession.create(@user)
      @event = stub_model(Event)
      @controller.stub!(:current_user).and_return(@user)
      @user.events.stub!(:find).and_return(@event)
      @event.should_receive(:update_attribute).with(:map, nil)
      delete :destroy, :event_id => 12
      response.should be_success
    end
  end

end
