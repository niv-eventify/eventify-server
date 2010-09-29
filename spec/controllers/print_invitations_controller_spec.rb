require File.dirname(__FILE__) + '/../spec_helper'

describe PrintInvitationsController do

  it "should render some pdf" do
    event = Factory.create(:event)
    get :show, :id => event.id, :debug => true, :format => :pdf
    response.should be_success
    response.should render_template("show")
  end
end
