require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# FIXME: .should raise_error(ActionController::MethodNotAllowed) is an ugly hack. fix it!
describe PasswordsController do
  describe "route generation" do

    it "should NOT map { :controller => 'passwords', :action => 'index' }" do
      route_for(:controller => "passwords", :action => "index").should == {:controller => "landing_pages", :action => "show", :friendly_url => ["passwords"]}
    end

    it "should map { :controller => 'passwords', :action => 'new' } to /passwords/new" do
      route_for(:controller => "passwords", :action => "new").should == "/passwords/new"
    end

    it "should NOT map { :controller => 'passwords', :action => 'show', :id => '1'}" do
      route_for(:controller => "passwords", :action => "show", :id => "1").should == {:controller => "landing_pages", :action => "show", :friendly_url => ["passwords","1"]}
    end

    it "should map { :controller => 'passwords', :action => 'edit', :id => '1' } to /passwords/1/edit" do
      route_for(:controller => "passwords", :action => "edit", :id => "1").should == "/activate/1"
    end

    it "should map { :controller => 'passwords', :action => 'update' } to /password" do
      route_for(:controller => "passwords", :action => "update").should == {:path => "/password", :method => :put}
    end

    it "should NOT map { :controller => 'passwords', :action => 'destroy', :id => '1' }" do
      route_for(:controller => "passwords", :action => "destroy", :id => "1").should == route_for(:controller => "landing_pages", :action => "show", :friendly_url => ["passwords","1"])
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'passwords', action => 'index' } from GET /passwords" do
      params_from(:get, "/passwords").should == {:controller => "landing_pages", :action => "show", :friendly_url => ["passwords"]}
    end

    it "should generate params { :controller => 'passwords', action => 'new' } from GET /passwords/new" do
      params_from(:get, "/passwords/new").should == {:controller => "passwords", :action => "new"}
    end

    it "should generate params { :controller => 'passwords', action => 'create' } from POST /passwords" do
      params_from(:post, "/passwords").should == {:controller => "passwords", :action => "create"}
    end

    it "should generate params { :controller => 'passwords', action => 'show', id => '1' } from GET /passwords/1" do
      params_from(:get, "/passwords/1").should == {:controller => "landing_pages", :action => "show", :friendly_url => ["passwords","1"]}
    end

    it "should generate params { :controller => 'passwords', action => 'edit', id => '1' } from GET /passwords/1;edit" do
      params_from(:get, "/passwords/1/edit").should == {:controller => "passwords", :action => "edit", :id => "1"}
    end

    it "should generate params { :controller => 'passwords', action => 'update', id => '1' } from PUT /passwords/1" do
      params_from(:put, "/passwords/1").should == {:controller => "passwords", :action => "update", :id => "1"}
    end

    it "should generate params { :controller => 'passwords', action => 'destroy', id => '1' } from DELETE /passwords/1" do
      params_from(:delete, "/passwords/1").should == {:controller => "landing_pages", :action => "show", :friendly_url => ["passwords","1"]}
    end
  end
end
