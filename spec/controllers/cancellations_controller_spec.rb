require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CancellationsController do

  setup :activate_authlogic
  
  describe "not logged in user" do
    [:edit, :update].each do |a|
      describe_action(a) do
        before(:each) do
          @params = {:id => 1}
        end
        it_should_require_login
      end
    end
  end

  describe "smth to send" do
    integrate_views

    before(:each) do
      @event = Factory.create(:cancelled_event)
      UserSession.create(@event.user)
      controller.current_user.events.stub!(:find).and_return(@event)
    end

    it "should render email form" do      
      @event.guests.stub!(:invited_stats).and_return({:total => 2, :email => 2, :sms => 0})
      get :edit, :id => @event.id
      response.should be_success
      response.body.should =~ /Send following email to 2 guests/
      response.body.should_not =~ /Send following message/
    end

    it "should render sms form" do
      @event.guests.stub!(:invited_stats).and_return({:total => 2, :email => 0, :sms => 2})
      get :edit, :id => @event.id
      response.should be_success
      response.body.should_not =~ /Send following email/
      response.body.should =~ /Send following message to 2 guests/
    end
  end

  describe "sending" do
    before(:each) do
      @event = Factory.create(:cancelled_event)
      UserSession.create(@event.user)
      @event.guests.stub!(:invited_stats).and_return({:total => 1})
      controller.current_user.events.stub!(:find).and_return(@event)    
    end

    it "nothing to do" do
      @event.should_not_receive(:send_cancellation!)
      put :update, :id => @event.id, :event => {}
      @event.cancellation_sent_at.should be_nil
      response.should redirect_to(summary_path(@event))
      @event.reload.should_not be_going_to_send_cancellation
    end

    it "should not send if cant validate" do
      @event.should_not_receive(:send_cancellation!)
      put :update, :id => @event.id, :event => {:cancel_by_email => "true"}
      response.should be_success
    end

    it "should send" do
      @event.should_receive(:send_cancellation!)
      put :update, :id => @event.id, :event => {
        :cancel_by_email => "true", 
        :cancel_by_sms => "true", 
        :cancellation_email_subject => "subj", 
        :cancellation_email => "message",
        :cancel_by_sms => "sms"}
      @event.reload.cancellation_sent_at.should_not be_nil
      response.should redirect_to(summary_path(@event))
    end
  end

  describe "nothing to send" do
    before(:each) do
      @event = Factory.create(:cancelled_event)
      UserSession.create(@event.user)
      @event.guests.stub!(:invited_stats).and_return({:total => 0})
      controller.current_user.events.stub!(:find).and_return(@event)
    end

    it "should redirect to summary path on edit" do
      get :edit, :id => @event.id
      response.should redirect_to(summary_path(@event))
    end

    it "should redirect to summary path on update" do
      put :update, :id => @event.id
      response.should redirect_to(summary_path(@event))      
    end
  end
end
