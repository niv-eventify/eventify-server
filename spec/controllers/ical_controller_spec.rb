require File.dirname(__FILE__) + '/../spec_helper'

describe IcalController do
  
  setup :activate_authlogic

  describe "event" do
    before(:each) do
      @event = Factory.create(:event)
    end
    
    it "should render ical for logged in user by event" do
      UserSession.create(@event.user)
      get :show, :event_id => @event.id
      response.should be_success
      response.body.should =~ /#{@event.name}/
      response.body.should =~ /BEGIN:VEVENT/
    end


    it "should not allow access to other user" do
      UserSession.create(Factory.create(:user))
      lambda {get :show, :event_id => @event.id}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "guest" do
    before(:each) do
      @guest = Factory.create(:guest_with_token)
    end

    it "should render ical for guest" do    
      get :show, :rsvp_id => @guest.email_token
      response.should be_success
      response.body.should =~ /#{@guest.event.name}/
      response.body.should =~ /BEGIN:VEVENT/    
    end

    it "should not allow access to other guest" do
      lambda {get :show, :rsvp_id => "someothertocket"}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

end
