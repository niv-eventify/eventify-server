require 'spec_helper'

describe GuestsMessagesController do
  setup :activate_authlogic
  integrate_views

  before(:each) do
    @event = Factory.create(:event)
    UserSession.create(@event.user)
  end
  
  it "should render new" do
    xhr :get, :new, :event_id => @event.id
    response.should be_success
    response.should render_template(:new)
  end

  it "should create guests message" do
    lambda {
      xhr :post, :create, :event_id => @event.id, :guests_message => {:subject => "some subject", :body => "some body"}
    }.should change(GuestsMessage, :count).by(1)
    response.should be_success
  end  

end
