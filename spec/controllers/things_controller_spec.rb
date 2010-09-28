require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ThingsController do
  setup :activate_authlogic
  integrate_views

  before(:each) do
    @event = Factory.create(:event)
    UserSession.create(@event.user)
  end

  it "should render index" do
    Event.stub!(:find).and_return(@event)

    thing = stub_model(Thing, :event_id => @event.id)
    things = [thing, thing]
    Thing.stub!(:find).and_return(things)

    xhr :get, :index, :event_id => @event.id
    response.should be_success
    response.should render_template(:index)
    assigns[:things].should == things
  end
  
  it "should render edit" do
    Event.stub!(:find).and_return(@event)
    thing = stub_model(Thing,:event_id => @event.id,:name => 'some name',:amount => 1)
    Thing.stub!(:find).and_return(thing)
    xhr :get, :edit, :event_id => @event.id, :id => 1  , :attribute => 'name'
    response.should render_template(:edit)
  end  
 
  it "should create thing" do
    lambda {
      xhr :post, :create, :event_id => @event.id, :thing => {:name => "some name", :amount => 1}
    }.should change(Thing, :count).by(1)
    response.should be_success
  end 

  it "should delete" do
    thing = stub_model(Thing)
    Thing.stub!(:find).and_return(thing)
    thing.stub!(:destroy).and_return(true)
    xhr :delete, :destroy, :event_id => @event.id, :id => 1
    response.should render_template(:destroy)
  end 

end
