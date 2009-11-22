require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactsController do
  setup :activate_authlogic
  
  describe "not logged in" do
    [:index, :new, :edit, :destroy, :create, :update].each do |a|
      describe_action(a) do
        before(:each) do
          @params = {:id => 1}
        end
        it_should_require_login
      end
    end
  end

  describe "logged in" do

    integrate_views

    before(:each) do
      @admin = Factory.create(:active_user)
      UserSession.create(@admin)
    end

    it "should render index" do
      @contact = stub_model(Contact)
      @contacts = [@contact]
      stub_pagination(@contacts)
      @contacts.stub!(:paginate).and_return(@contacts)
      @controller.current_user.stub!(:contacts).and_return(@contacts)

      get :index
      response.should be_success
      response.should render_template(:index)
      assigns[:contacts].should == @contacts
    end

    it "should render new" do
      get :new
      response.should be_success
      response.should render_template(:new)
    end

    it "should render edit" do
      @contact = stub_model(Contact)
      @contacts = mock("contacts")
      @contacts.stub!(:find).with("1").and_return(@contact)
      @controller.current_user.stub!(:contacts).and_return(@contacts)
      get :edit, :id => 1
      response.should render_template(:edit)
    end

    it "should update" do
      @contact = stub_model(Contact)
      @contacts = mock("contacts")
      @contacts.stub!(:find).with("1").and_return(@contact)
      @controller.current_user.stub!(:contacts).and_return(@contacts)

      @contact.should_receive(:update_attributes).and_return(true)
      put :update, :id => 1, :contact => {:name => "foo", :email => "foo@bar.com", :city => "New York"}
      response.should redirect_to("/contacts")
    end

    it "should mark as removed" do
      @contact = stub_model(Contact)
      @contacts = mock("contacts")
      @contacts.stub!(:find).with("1").and_return(@contact)
      @controller.current_user.stub!(:contacts).and_return(@contacts)

      @contact.should_receive(:removed_at=)
      @contact.should_receive(:save!)
      delete :destroy, :id => 1
      response.should redirect_to("/contacts")
    end
  end
end
