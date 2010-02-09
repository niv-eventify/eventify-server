require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Guest do
  describe "validations" do
    before(:each) do
      @guest = Guest.new
    end

    it "should validate email" do
      @guest.email = "sdfasfa"
      @guest.should_not be_valid
      @guest.errors.on(:email).should_not be_blank
    end

    it "should validate email or phone" do
      @guest.should_not be_valid
      @guest.errors.on(:email).should =~ /provide email or mobile phone/
    end
  end

  describe "send email invitation" do
    before(:each) do
      @guest = Factory.create(:guest)
    end

    it "should update email_invitation_sent_at and email_token" do
      @guest.email_invitation_sent_at.should be_nil
      @guest.email_token.should be_nil
      @guest.send_email_inviation!
      @guest.email_invitation_sent_at.should_not be_nil
      @guest.email_token.should_not be_nil
    end

    it "should not change email_token" do
      @guest.email_token = "foobar"
      @guest.save

      @guest.send_email_inviation!
      @guest.email_token.should == "foobar"
    end
  end
end
