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

    describe "edit" do
      integrate_views

      before(:each) do
        @user = Factory.create(:active_user)
        UserSession.create(@user)
        @event = stub_model(Event)
        controller.current_user.events.stub!(:find).and_return(@event)
        @event.stub(:payments).and_return([])
      end

      it "should not render cancel sms button" do
        @event.stub(:payment_required?).and_return(false)
        @event.stub(:require_payment_for_sms?).and_return(false)
        get :edit, :id => @event
        response.should be_success
        response.should render_template("edit")
        response.body.should_not =~ /Don't send SMS invitations/
      end

      it "should render cancel sms button" do
        @event.stub(:require_payment_for_sms?).and_return(true)
        get :edit, :id => @event
        response.should be_success
        response.should render_template("edit")
        response.body.should =~ /Don't send SMS invitations/
      end
    end
    describe "update" do
      integrate_views

      before(:each) do
        @user = Factory.create(:active_user)
        UserSession.create(@user)
        @event = Factory.create(:event)
        controller.current_user.events.stub!(:find).and_return(@event)
      end
      
      it "should send invitations" do
        @event.stub!(:valid?).and_return(true)
        @event.stub!(:save).and_return(true)
        @event.should_receive(:send_invitations)
        post :update, :id => @event.id, :event => {:send_invitations_now => true}
        response.should redirect_to(invitation_path(@event))
      end

      it "should fail on validations" do
        @event.stub!(:valid?).and_return(false)
        @event.stub!(:errors).and_return([:error])
        @event.should_not_receive(:send_invitations)
        post :update, :id => @event.id, :event => {:send_invitations_now => true}
      end
    end
  end
end
