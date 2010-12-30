require File.dirname(__FILE__) + '/../spec_helper'

describe RemindersController do
  setup :activate_authlogic
  integrate_views

  before(:each) do
    @event = Factory.create(:event)
    UserSession.create(@event.user)
  end

  it "should render index" do
    Event.stub!(:find).and_return(@event)

    reminder = stub_model(Reminder, :event_id => @event.id, :send_reminder_at => Time.now.utc)
    reminders = [reminder, reminder]
    Reminder.stub!(:find).and_return(reminders)

    xhr :get, :index, :event_id => @event.id
    response.should be_success
    response.should render_template(:index)
    assigns[:reminders].should == reminders  
  end
  
  it "should render new" do
    xhr :get, :new, :event_id => @event.id
    response.should be_success
    response.should render_template(:new)
  end

  it "should render edit" do
    @reminder = @event.reminders.last
    Reminder.stub!(:find).and_return(@reminder)
    xhr :get, :edit, :event_id => @event.id, :id => 1
    response.should render_template(:edit)
  end  

  it "should create reminder" do
    lambda {
      xhr :post, :create, :event_id => @event.id, :reminder => {:before_units => "hours", :before_value => 1, :by_sms => true}
    }.should change(Reminder, :count).by(1)
    response.should be_success
  end

  it "should update" do
    Event.stub!(:find).and_return(@event)    
    reminder = stub_model(Reminder, :event_id => @event.id, :send_reminder_at => Time.now.utc)
    reminders = [reminder,reminder]   
    reminders.stub!(:find).with("1").and_return(reminder)
    @event.stub!(:reminders).and_return(reminders)
    reminder.should_receive(:update_attributes).and_return(true)

    xhr :put, :update, :event_id => @event.id, :id => 1, :reminder => {:before_units => "hours", :before_value => 1, :by_sms => true, :sms_message => "some"}
    response.should be_success
  end 

  it "should delete" do
    @reminder = stub_model(Reminder)
    Reminder.stub!(:find).and_return(@reminder)
    @reminder.stub!(:destroy).and_return(true)
    xhr :delete, :destroy, :event_id => @event.id, :id => 1
    response.should render_template(:destroy)
  end  

end
