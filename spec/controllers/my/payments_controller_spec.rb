require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe My::PaymentsController do

  setup :activate_authlogic


  describe "not logged in user" do
    describe_action(:index) do
      it_should_require_login
    end
  end

  describe "logged in user" do
    integrate_views 

    it "should render index" do
      @event = Factory.create(:event)
      UserSession.create(@event.user)
      payment = stub_model(Payment, :amount => 123, :event_id => @event.id, :paid_at => Time.now.utc)
      payments = [payment, payment]
      Payment.stub!(:find).and_return(payments)

      get :index
      response.should be_success
      response.body.should =~ /1\.23/
    end

  end
end
