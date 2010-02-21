require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SummaryController do

  setup :activate_authlogic


  describe "not logged in user" do
    describe_action(:show) do
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
    end

    it "should render summary" do
      controller.current_user.events.stub!(:find).and_return(@event)
      @event.should_receive(:invitations_to_send_counts).and_return({:email => 2, :sms => 3,:total => 5})
      get :show, :event_id => @event
      response.should be_success
    end
  end

end
