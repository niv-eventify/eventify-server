require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaymentsController do

  setup :activate_authlogic


  describe "not logged in user" do
    describe_action(:create) do
      before(:each) do
        @params = {:event_id => 1}
      end
      it_should_require_login
    end
  end

end
