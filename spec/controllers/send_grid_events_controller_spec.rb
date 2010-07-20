require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SendGridEventsController do

  describe "event" do
    before(:each) do
      @event = stub_model(Event, :id => 123)
      Event.stub!(:find).with("123").and_return(@event)
    end

    it "should bounce a guest" do
      @event.should_receive(:bounce_guest_by_email!).with("email", "status", "reason")
      post :create, :category => "event_#{@event.id}", :event => "bounce", :status => "status", :reason => "reason", :email => "email"
      response.should be_success
    end
  end

  describe "junk" do
    it "should not fail" do
      post :create
      response.should be_success
    end
  end
end
