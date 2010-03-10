require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InvitationsController do

  setup :activate_authlogic

  describe "create" do
    describe "not logged in user" do
      describe_action(:create) do
        before(:each) do
          @params = {:event_id => 1}
        end
        it_should_require_login
      end
    end

    describe "owner" do
      integrate_views

      before(:each) do
        @user = Factory.create(:active_user)
        UserSession.create(@user)
        @event = stub_model(Event)
        controller.current_user.events.stub!(:find).and_return(@event)
      end

      it "should redirect back to payments when need to pay for event" do
        @event.stub(:send_invitations).and_return(false)
        post :create, :event_id => @event.id
        response.should redirect_to("/events/#{@event.id}/payments")
        response.flash[:error].should == "Payments are not completed yet"
      end

      it "should send inviations" do
        @event.stub(:send_invitations).and_return(true)
        post :create, :event_id => @event.id
        response.should redirect_to("/events")
        response.flash[:notice].should =~ /are being sent/
      end
    end
  end

  describe "guests" do
    before(:each) do
      @guest = Factory.create(:guest_with_token)
      @guest.reload.rsvp.should be_nil
    end

    it "should show event for a guest" do
      get :show, :id => @guest.email_token
      response.should be_success
      response.should render_template("show")
    end

    it "should be able to change rsvp" do
      xhr :put, :update, :id => @guest.email_token, :guest => {:rsvp => 2}
      response.should be_success
      @guest.reload.rsvp.should == 2
    end
  end

end
