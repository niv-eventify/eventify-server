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


  describe "logged in user" do
    integrate_views
    before(:each) do
      @event = Factory.create(:event)
      UserSession.create(@event.user)
      Event.stub!(:find).and_return(@event)
    end


    it "should render new" do
      get :new, :event_id => @event.id
      response.should be_success
      response.should render_template(:new)
    end

    it "should create a payment" do
      @event.stub!(:total_sms_count).and_return(2)
      post :create, :event_id => @event.id, :payment => {:sms_plan => 20, :emails_plan => 20, :prints_plan => 0, :amount => 700}
      assigns[:payment].should be_new_record
      response.should_not be_redirect
    end

    it "should fail on validations" do
      @event.stub!(:total_sms_count).and_return(2)
      post :create, :event_id => @event.id, :payment => {:sms_plan => 25, :emails_plan => 100, :prints_plan => 0, :amount => 10}
      response.should be_success
    end

    describe "edit/update" do
      before(:each) do
        @payment = stub_model(Payment, :event_id => @event.id, :user => @event.user, :amount => 500, :pay_emails => 10, :pay_sms => 20)
        Payment.stub!(:find).and_return(@payment)
      end

      it "should render pay form" do
        get :edit, :event_id => @event.id, :id => @payment.id
        response.should be_success
        response.should render_template(:edit)
      end

      describe "pay" do
        it "should render edit when payment error" do
          @payment.should_receive(:pay!).and_raise(PaymentError)
          put :update, :event_id => @event.id, :id => @payment.id, :payment => {}
          response.should be_success
          response.should render_template(:edit)
        end

        it "should render edit when payment is not valid" do
          @payment.should_receive(:pay!).and_raise(ActiveRecord::RecordInvalid.new(@payment))
          put :update, :event_id => @event.id, :id => @payment.id, :payment => {}
          response.should be_success
          response.should render_template(:edit)
        end

        it "should redirect to inviations when succesfuly paid" do
          @payment.should_receive(:pay!).and_return(true)
          put :update, :event_id => @event.id, :id => @payment.id, :payment => {}, :back => "invitations"
          response.should redirect_to(edit_invitation_url(@event.id, :locale => "he", :protocol => "http://"))
        end

        it "should redirect to cancellations when succesfuly paid" do
          @payment.should_receive(:pay!).and_return(true)
          put :update, :event_id => @event.id, :id => @payment.id, :payment => {}, :back => "cancellations"
          response.should redirect_to(edit_cancellation_url(@event.id, :locale => "he", :protocol => "http://"))
        end
      end
    end
  end
end
