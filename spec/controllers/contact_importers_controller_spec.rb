require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContactImportersController do

  setup :activate_authlogic
  
  describe "not logged in" do
    [:index, :edit, :show, :update].each do |a|
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
      @user = Factory.create(:active_user)
      UserSession.create(@user)
    end
    
    describe "show" do
      before(:each) do
        @importer = stub_model(ContactImporter, :contact_source => "gmail")
        @controller.current_user.contact_importers.stub!(:find_by_contact_source).with("gmail").and_return(@importer)
      end
      it "should show in progress" do
        @importer.completed_at = nil
        get :show, :id => "gmail"
        response.should be_success
        response.body.should =~ /GMail/
      end

      it "should show completed" do
        @importer.completed_at = Time.now.utc
        @importer.contacts_imported = 20
        get :show, :id => "gmail"
        response.should be_success
        response.body.should =~ /imported/
      end

      it "should show error" do
        @importer.completed_at = Time.now.utc
        @importer.last_error = "smth is wrong"
        get :show, :id => "gmail"
        response.should be_success
        response.body.should =~ /smth is wrong/
      end
    end

    describe "edit" do
      it "should render success" do
        @importer = stub_model(ContactImporter, :contact_source => "gmail")
        @controller.current_user.contact_importers.stub!(:reset_source!).and_return(@importer)
        get :edit, :id => "gmail"
        response.should be_success
      end
    end

    describe "update" do
      ["gmail", "csv"].each do |s|
        it "should render errors on #{s}" do
          put :update, :id => s, :contact_importer => {}
          response.should be_success
          assigns[:contact_importer].errors.should_not be_blank
        end
      end
      
      describe "import" do
        before(:each) do
          @importer = stub_model(ContactImporter)
          @controller.current_user.contact_importers.stub!(:reset_source!).and_return(@importer)
          @importer.stub!(:valid?).and_return(true)
        end
        it "should run importing for csv" do
          @importer.stub!(:contact_source).and_return("csv")
          @importer.should_receive(:import!)
          put :update, :id => "csv", :contact_importer => {:csv => "file"}
          response.should redirect_to("/contact_importers/csv")
        end
        (ContactImporter::SOURCES.keys - ["csv"]).each do |s|
          it "should delayed run importing for #{s}" do
            @importer.stub!(:contact_source).and_return(s)
            @importer.should_receive(:send_later).with(:import!, "user", "password")
            put :update, :id => s, :contact_importer => {:username => "user", :password => "password"}
            response.should redirect_to("/contact_importers/#{s}")
          end          
        end
      end
    end
  end
end
