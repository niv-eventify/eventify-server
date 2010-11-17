require File.dirname(__FILE__) + '/../spec_helper'

describe RsvpsController do

  setup :activate_authlogic
  integrate_views

  describe "guests" do
    before(:each) do
      @guest = Factory.create(:guest_with_token)
      @guest.reload.rsvp.should be_nil
      @guest.event.stub!(:design).and_return(stub_model(Design, :text_top_y => 1, :text_top_x => 1, :text_width => 100, :text_height => 100))
      preview = mock("preview")
      preview.stub!(:url).and_return("foobar")
      @guest.event.design.stub!(:preview).and_return(preview)
      Guest.stub!(:find_by_email_token).and_return(@guest)
    end

    it "should show event for a guest" do
      get :show, :id => @guest.email_token, :more => "true"
      response.should be_success
      response.should render_template("show_more")
    end

    it "should be able to change rsvp" do
      xhr :put, :update, :id => @guest.email_token, :guest => {:rsvp => 2}
      response.body.should =~ /\/rsvps\/#{@guest.email_token}\?more=true/
      @guest.reload.rsvp.should == 2
    end

    it "should redirect to corrent locale" do
      @guest.event.stub!(:language).and_return("en")
      get :show, :id => @guest.email_token
      response.should redirect_to("http://en.test.host/rsvps/#{@guest.email_token}")
    end

    it "should render guests" do
      @guest.event.stub!(:allow_seeing_other_guests).and_return(true)
      get :show, :id => @guest.email_token, :more => "true"
      response.body.should =~ /Guests/
    end

    it "should not render guest" do
      @guest.event.stub!(:allow_seeing_other_guests).and_return(false)
      get :show, :id => @guest.email_token, :more => "true"
      response.body.should !~ /Guests/
    end
  end

end
