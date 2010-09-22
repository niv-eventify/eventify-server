require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::EventsController do

  setup :activate_authlogic

  describe "logged in user not admin" do
    before(:each) do
      @user = Factory.create(:user)
      UserSession.create(@user)
    end

    describe_action(:index) do
      it_should_redirect_to "/"
    end
  end

  describe "not logged in user" do
    describe_action(:index) do
      it_should_require_login
    end
  end


  describe "admin" do

    integrate_views

    before(:each) do
      @user = Factory.create(:admin)
      UserSession.create(@user)
      Factory.create(:event)
    end

    it "should render index" do
      get :index
      response.should be_success
    end
  end
end
