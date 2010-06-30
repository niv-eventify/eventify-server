require File.dirname(__FILE__) + '/../spec_helper'

describe DesignsController do
  setup :activate_authlogic

  integrate_views

  it "should render show" do
    d = stub_model(Design, :text_top_y => 1, :text_top_x => 1, :text_width => 100, :text_height => 100)

    Design.stub!(:find).and_return(d)
    Category.should_receive(:find).with("1").and_return(stub_model(Category))
    Category.should_receive(:find).with(:all).and_return([stub_model(Category, :name => "a"), stub_model(Category, :name => "b")])
    collection = [d, d]
    stub_pagination(collection)
    controller.stub(:collection).and_return(collection)
    get :show, :event_id => 0, :category_id => 1
    response.should be_success
  end
end