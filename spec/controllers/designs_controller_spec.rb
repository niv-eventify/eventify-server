require File.dirname(__FILE__) + '/../spec_helper'

describe Admin::DesignsController do
  setup :activate_authlogic

  describe "not admin" do
    before(:each) do
      @user = Factory.create(:user)
      UserSession.create(@user)
    end

    [:index, :show, :update, :destroy, :create].each do |action|
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
    end

    it "should render index" do
      designs = [stub_model(Design, :category => stub_model(Category))]
      Design.available.stub!(:paginate).and_return(designs)
      get :index
      response.should be_success
    end

    it "should render show" do
      @design = stub_model(Design, :category => stub_model(Category))
      urler = mock("urler")
      urler.stub!(:url).and_return("http://image.com/image.png")
      @design.stub!(:preview).and_return(urler)
      @design.stub!(:background).and_return(urler)
      @design.stub!(:card).and_return(urler)
      Design.stub!(:find).and_return(@design)
      get :show, :id => @design.id
      response.should be_success
    end

    it "should create a design" do
      design = mock_model(Design, :category_id => 12)
      design.should_receive(:creator_id=).with(@user.id).and_return(true)
      design.should_receive(:save).and_return(true)
      Design.stub(:new).and_return(design)
      post :create, :design => {:category_id => 12}
      assigns[:design].should == design
      response.should redirect_to(admin_designs_path)
    end

    it "should update disabled_at" do
      design = mock_model(Design, :category => stub_model(Category))
      Design.stub!(:find).and_return(design)
      design.should_receive(:disabled_at=)
      design.should_receive(:save!).and_return(true)
      delete :destroy, :id => design.id
      response.should redirect_to(admin_designs_path)
    end
  end

end
