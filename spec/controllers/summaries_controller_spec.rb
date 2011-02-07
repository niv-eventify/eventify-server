require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SummariesController do

  setup :activate_authlogic
  integrate_views

  before(:each) do
    @user = Factory.create(:user)
    UserSession.create(@user)
    @event = stub_model(Event, :starting_at => 10.days.from_now.utc, :user => @user, :default_sms_message => "foo bar", :default_sms_message_for_resend => "bar foo")
    @event.stub!(:design).and_return(stub_model(Design, :text_top_x => 0, :text_top_y => 0, :text_width => 900, :text_height => 600, :text_align => "center", :color => "rgb(10,10,10)", :font_body => "arial"))
    controller.current_user.events.stub!(:find).and_return(@event)
  end

  it "should render summary" do
    @event.stub!(:stage_passed).and_return(4)
    get :show, :id => @event.id
    response.should be_success
  end

  (1..3).each do |s|
    it "should redirect to send invitaions when stage is #{s}" do
      @event.stub!(:stage_passed).and_return(s)
      get :show, :id => @event.id
      response.should redirect_to(edit_invitation_path(@event.id))
    end
  end

  (1..4).each do |s|
    it "should render  summary if cancelled on stage #{s}" do
      @event.stub!(:stage_passed).and_return(s)
      @event.stub!(:canceled?).and_return(true)
      get :show, :id => @event.id
      response.should be_success
    end
  end
end
