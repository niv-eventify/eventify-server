require File.dirname(__FILE__) + '/../spec_helper'

describe RsvpsController do

  setup :activate_authlogic
  integrate_views

  describe "guests" do
    before(:each) do
      @guest = Factory.create(:guest_with_token)
      @guest.reload.rsvp.should be_nil
      @guest.event.stub!(:design).and_return(stub_model(Design))
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
      response.should be_success
      @guest.reload.rsvp.should == 2
    end
  end

end
