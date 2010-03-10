require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaymentsController do

  setup :activate_authlogic


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
      @event.stub(:payments).and_return([])
    end

    it "should not render cancel sms button" do
      @event.stub(:payment_required?).and_return(false)
      @event.stub(:require_payment_for_sms?).and_return(false)
      get :index, :event_id => @event
      response.should be_success
      response.should render_template("index")
      response.body.should_not =~ /Don't send SMS invitations/
    end

    it "should render cancel sms button" do
      @event.stub(:require_payment_for_sms?).and_return(true)
      get :index, :event_id => @event
      response.should be_success
      response.should render_template("index")
      response.body.should =~ /Don't send SMS invitations/
    end
  end

end
