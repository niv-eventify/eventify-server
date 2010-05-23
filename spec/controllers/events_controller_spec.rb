require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventsController do

  setup :activate_authlogic

  def create_event(user)
    @user = Factory.create(user)
    UserSession.create(@user)
    post :create, :event => {:category_id => 1, :design_id => 1, :name => "some name", :starting_at => 10.days.from_now}
  end

  describe "activated" do
    describe "create - success" do
      before(:each) do
        ::Astrails::Auth::Mailer.should_not_receive(:deliver_activation_instructions)
        create_event(:active_user)
      end

      it "should create a event" do
        assigns[:event].should_not be_new_record
      end

      it "should redirect to guests path" do
        response.should redirect_to(event_guests_path(assigns[:event], :wizard => true))
      end

      it "should create activated event" do
        assigns[:event].user_is_activated.should be_true
      end
    end
  end

  describe "not activated" do
    before(:each) do
      ::Astrails::Auth::Mailer.should_not_receive(:deliver_activation_instructions)
      create_event(:user)
    end

    it "should create a event" do
      assigns[:event].should_not be_new_record
    end

    it "should redirect to guests path" do
      response.should redirect_to(event_guests_path(assigns[:event], :wizard => true))
    end

    it "should create not activated event" do
      assigns[:event].user_is_activated.should_not be_true
    end
  end

  describe "with user on the fly" do
    before(:each) do
      ::Astrails::Auth::Mailer.should_receive(:deliver_activation_instructions)
      post :create, :event => {:category_id => 1, :design_id => 1, :name => "some name", :starting_at => 10.days.from_now, 
        :user_attributes => {:name => "foobar", :email => "onthefly@foobar.com"}}
    end

    it "should create a event" do
      assigns[:event].should_not be_new_record
    end


    it "should redirect to guests path" do
      response.should redirect_to(event_guests_path(assigns[:event], :wizard => true))
    end

    it "should create not activated event" do
      assigns[:event].user_is_activated.should_not be_true
    end

    it "should create a user" do
      assigns[:event].user.should_not be_new_record
      assigns[:event].user.name.should == "foobar"
      assigns[:event].user.email.should == "onthefly@foobar.com"
      assigns[:event].user.activated_at.should be_nil
    end
  end
end
