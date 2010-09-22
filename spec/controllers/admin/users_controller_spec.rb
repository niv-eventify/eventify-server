require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::UsersController do


  setup :activate_authlogic

  describe "logged in user not admin" do
    before(:each) do
      @user = Factory.create(:user)
      UserSession.create(@user)
    end

    [:index, :update].each do |action|
      describe_action(action) do
        before(:each) do
          @params = {:id => 1}
        end
        it_should_redirect_to "/"
      end
    end
  end

  describe "not logged in user" do
    [:index, :update].each do |action|
      describe_action(action) do
        before(:each) do
          @params = {:id => 1}
        end
        it_should_require_login
      end
    end
  end

  describe "admin" do

    integrate_views

    before(:each) do
      @user = Factory.create(:admin)
      UserSession.create(@user)
      @u = Factory.create(:user)
    end


    it "should render users" do
      get :index
      response.should be_success
    end

    it "should toggle is_free" do
      @u.reload.should_not be_is_free
      put :update, :id => @u.id
      response.should be_success
      @u.reload.should be_is_free
    end
  end
end
