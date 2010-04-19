require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InvitationsController do

  setup :activate_authlogic

  describe "create" do
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
  end

  describe "show" do
    integrate_views
    before(:each) do
      @user = Factory.create(:active_user)
      UserSession.create(@user)
      @event = stub_model(Event)
      controller.current_user.events.stub!(:find).and_return(@event)
      @event.stub(:payments).and_return([])
    end

    it "should render show" do
      get :show, :id => @event
      response.should be_success
      response.should render_template("show")
    end
  end

  describe "edit" do
    integrate_views

    before(:each) do
      @user = Factory.create(:active_user)
      UserSession.create(@user)
      @event = stub_model(Event)
      controller.current_user.events.stub!(:find).and_return(@event)
      @event.stub(:payments).and_return([])
    end

    it "should redirect to summary page when nothing to send" do
      @event.stub!(:invitations_to_send_counts).and_return({:total => 0})
      get :edit, :id => @event
      response.should redirect_to("/summary/#{@event.id}")
    end

    it "should render send form" do
      @event.stub!(:invitations_to_send_counts).and_return({:total => 3, :email => 2, :sms => 1})
      get :edit, :id => @event
      response.should be_success
      response.body.should =~ /Invitations to send: 2 by email and 1 by SMS/
      response.body.should =~ /event_send_invitations_now/
    end

    it "should not ask for sms messages when only email invitations are there" do
      @event.stub!(:invitations_to_send_counts).and_return({:total => 3, :email => 3, :sms => 0})
      get :edit, :id => @event
      response.should be_success
      response.body.should_not =~ /event_sms_message/
      response.body.should_not =~ /host_mobile_number/
    end

    it "should ask for sms message when need to send sms" do
      @event.stub!(:invitations_to_send_counts).and_return({:total => 3, :email => 0, :sms => 3})
      get :edit, :id => @event
      response.should be_success
      response.body.should =~ /event_sms_message/
      response.body.should =~ /host_mobile_number/      
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
      @user = Factory.create(:active_user)
      UserSession.create(@user)
      @event = Factory.create(:event)
      controller.current_user.events.stub!(:find).and_return(@event)
    end
    
    it "should send invitations" do
      @event.stub!(:valid?).and_return(true)
      @event.stub!(:save).and_return(true)
      @event.should_receive(:send_invitations)
      post :update, :id => @event.id, :event => {:send_invitations_now => true}
      response.should redirect_to(invitation_path(@event))
    end

    it "should fail on validations" do
      @event.stub!(:valid?).and_return(false)
      @event.stub!(:errors).and_return([:error])
      @event.errors.stub!(:on)
      @event.should_not_receive(:send_invitations)
      post :update, :id => @event.id, :event => {:send_invitations_now => true}
    end
  end
end
