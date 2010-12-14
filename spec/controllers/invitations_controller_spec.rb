require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InvitationsController do

  setup :activate_authlogic

  describe "disabled user" do
    [:show, :edit, :update].each do |a|
      describe_action(a) do
        before(:each) do
          @user = Factory.create(:disabled_user)
          @params = {:event_id => 1, :id => 1}
          UserSession.create(@user)
        end
        it "should redirect to profile_path" do
          eval_request
          response.should redirect_to(profile_path)
          response.flash[:error].should == "Your account has been disabled"
        end
      end
    end
  end

  describe "not logged in user" do
    [:show, :edit, :update].each do |a|
      describe_action(a) do
        before(:each) do
          @params = {:event_id => 1, :id => 1}
        end
        it_should_require_login
      end
    end
  end

  describe "show" do
    integrate_views
    before(:each) do
      @user = Factory.create(:active_user)
      UserSession.create(@user)
      @event = stub_model(Event)
      controller.current_user.events.stub!(:find).and_return(@event)
    end

    it "should render show" do
      get :show, :id => @event.id
      response.should be_success
      response.should render_template("show")
    end
  end

  describe "edit with inactive user" do
    integrate_views
    
    before(:each) do
      @user = Factory.create(:user)
      UserSession.create(@user)
      @event = stub_model(Event, :starting_at => 10.days.from_now.utc, :user => @user, :stage_passed => 3, :default_sms_message => "foo bar", :default_sms_message_for_resend => "bar foo")
      controller.current_user.events.stub!(:find).and_return(@event)
      guests = mock("guests")
      guests.stub!(:count).and_return(1)
      @event.stub(:guests).and_return(guests)
      Astrails.stub!(:good_time_to_send_sms?).and_return(true)
      @event.stub(:payments_required?).and_return(false)
      @event.stub!(:invitations_to_send_counts).and_return({:total => 0})
    end

    it "should render activation email sent" do
      get :edit, :id => @event.id
      response.should be_success
      response.body.should =~ /Instructions to activate your account have been emailed to you. Please check your email./
    end
  end

  describe "payments required" do
    before(:each) do
      @user = Factory.create(:active_user)
      UserSession.create(@user)
      @event = stub_model(Event, :starting_at => 10.days.from_now.utc, :user => @user, :stage_passed => 3, :default_sms_message => "foo bar", :default_sms_message_for_resend => "bar foo")
      controller.current_user.events.stub!(:find).and_return(@event)
      @event.stub!(:payments_required?).and_return(true)
      guests = mock("guests")
      guests.stub!(:count).and_return(1)
      @event.stub!(:guests).and_return(guests)
      @event.stub!(:invitations_to_send_counts).and_return({:total => 3, :email => 2, :sms => 1, :resend_email => 0, :resend_sms => 2})
    end

    it "should redirect on edit" do
      get :edit, :id => @event.id
      response.should redirect_to(new_event_payment_path(@event, :back => "invitations"))
    end

    it "should redirect on update" do
      put :update, :id => @event.id, :event => {}
      response.should redirect_to(new_event_payment_path(@event, :back => "invitations"))
    end
  end


  describe "edit" do
    integrate_views

    before(:each) do
      @user = Factory.create(:active_user)
      UserSession.create(@user)
      @event = stub_model(Event, :starting_at => 10.days.from_now.utc, :user => @user, :stage_passed => 3, :default_sms_message => "foo bar", :default_sms_message_for_resend => "bar foo")
      controller.current_user.events.stub!(:find).and_return(@event)
      guests = mock("guests")
      guests.stub!(:count).and_return(1)
      @event.stub(:guests).and_return(guests)
      @event.stub(:payments_required?).and_return(false)
      Astrails.stub!(:good_time_to_send_sms?).and_return(true)
    end

    it "should redirect to summary page when nothing to send" do
      @event.stub!(:stage_passed).and_return(4)
      @event.stub!(:invitations_to_send_counts).and_return({:total => 0})
      get :edit, :id => @event.id
      response.should redirect_to("/summary/#{@event.id}")
    end

    it "should redirect to summary if event cancelled" do
      @event.stub!(:invitations_to_send_counts).and_return({:total => 3, :email => 2, :sms => 1, :resend_email => 0, :resend_sms => 2})
      @event.stub!(:canceled?).and_return(true)
      get :edit, :id => @event.id
      response.should redirect_to("/summary/#{@event.id}")
    end

    it "should render send form" do
      @event.stub!(:invitations_to_send_counts).and_return({:total => 3, :email => 2, :sms => 1, :resend_email => 0, :resend_sms => 2})
      get :edit, :id => @event.id
      response.should be_success
      response.body.should =~ /Invitations to send: 2 by email and 1 by SMS/
      response.body.should =~ /Invitations to re-send: 0 by email and 2 by SMS/
    end

    it "should not ask for sms messages when only email invitations are there" do
      @event.stub!(:invitations_to_send_counts).and_return({:total => 3, :email => 3, :sms => 0, :resend_email => 0, :resend_sms => 0})
      get :edit, :id => @event.id
      response.should be_success
      response.body.should_not =~ /event_sms_message/
      response.body.should_not =~ /host_mobile_number/
      response.body.should_not =~ /event_sms_resend_message/
    end

    it "should ask for sms message when need to send sms" do
      @event.stub!(:invitations_to_send_counts).and_return({:total => 3, :email => 0, :sms => 3, :resend_email => 0, :resend_sms => 1})
      get :edit, :id => @event.id
      response.should be_success
      response.body.should =~ /event_sms_message/
      response.body.should =~ /host_mobile_number/
      response.body.should =~ /event_sms_resend_message/
    end
    # it "should not render cancel sms button" do
    #   @event.stub(:payment_required?).and_return(false)
    #   @event.stub(:require_payment_for_sms?).and_return(false)
    #   get :edit, :id => @event
    #   response.should be_success
    #   response.should render_template("edit")
    #   response.body.should_not =~ /Don't send SMS invitations/
    # end

    # it "should render cancel sms button" do
    #   @event.stub(:require_payment_for_sms?).and_return(true)
    #   get :edit, :id => @event
    #   response.should be_success
    #   response.should render_template("edit")
    #   response.body.should =~ /Don't send SMS invitations/
    # end
  end
  describe "update" do
    integrate_views

    before(:each) do
      @event = Factory.create(:event)
      UserSession.create(@event.user)
      controller.current_user.events.stub!(:find).and_return(@event)
      # @event.stub!(:guests).and_return(guests)
      @event.stub(:payments_required?).and_return(false)
    end

    it "should redirect if event in past" do
      controller.stub!(:check_guests).and_return(true)
      @event.stub!(:starting_at).and_return(1.day.ago)
      post :update, :id => @event.id
      response.should redirect_to(edit_event_path(@event))
      response.flash[:error].should == "Event start time is passed."
    end

    it "should redirect to guests path when no guests" do
      post :update, :id => @event.id
      response.should redirect_to(event_guests_path(@event))
    end

    it "should send invitations" do
      @event.stub!(:valid?).and_return(true)
      @event.stub!(:save).and_return(true)
      @event.should_receive(:send_invitations)
      controller.stub!(:check_guests).and_return(true)
      post :update, :id => @event.id
      response.should redirect_to(invitation_path(@event))
    end

    it "should fail on validations" do
      @event.stub!(:valid?).and_return(false)
      @event.stub!(:errors).and_return([:error])
      @event.errors.stub!(:on)
      @event.should_not_receive(:send_invitations)
      controller.stub!(:check_guests).and_return(true)
      post :update, :id => @event.id
      response.should be_success
    end
  end
end
