require File.dirname(__FILE__) + '/../../spec_helper'

describe "/users/show.html.haml" do
  setup :activate_authlogic
  before(:each) do
    @user = assigns[:user] = Factory.create(:user)
    @controller.stub!(:current_user).and_return(stub_model(User, :name => "john", :events => Event))
  end

  it "should render" do
    render "/users/show"
  end

  it "should_link_to users_path"
  it "should have more tests"
end
