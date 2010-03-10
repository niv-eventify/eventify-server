require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Guest do
  describe "validations" do
    before(:each) do
      @guest = Guest.new
      @guest.name = "goobar"
    end

    it "should validate email" do
      @guest.email = nil
      @guest.send_email = true
      @guest.should_not be_valid
      @guest.errors.on(:email).should_not be_blank
    end

    it "should validate phone" do
      @guest.mobile_phone = nil
      @guest.send_sms = true
      @guest.should_not be_valid
      @guest.errors.on(:mobile_phone).should_not be_blank
    end
  end

  describe "failures handling" do
    describe "sms" do
      describe "reset failures" do
        before(:each) do
          @guest = Factory.create(:guest_with_sms)
          @guest.sms_invitation_sent_at.should_not be_nil
          @guest.sms_invitation_failed_at.should_not be_nil
        end

        it "should not reset timestamps" do
          @guest.name = "foobar"
          @guest.save
          @guest.sms_invitation_sent_at.should_not be_nil
          @guest.sms_invitation_failed_at.should_not be_nil
        end

        it "should reset timestamps" do
          @guest.mobile_phone = "0520000000"
          @guest.save
          @guest.sms_invitation_sent_at.should be_nil
          @guest.sms_invitation_failed_at.should be_nil          
        end
      end
    end
  end

  describe "send sms invitation" do
    before(:each) do
      @guest = Factory.create(:guest_with_mobile)
      @guest.sms_invitation_sent_at.should be_nil
      @guest.sms_invitation_failed_at.should be_nil
    end

    it "should save failure time" do
      @guest.prepare_sms_invitation!(Time.now.utc)
      @guest.sms_invitation_sent_at.should_not be_nil
      @guest.sms_invitation_failed_at.should_not be_nil
    end

    it "should send sms" do
      Cellact::Sender.stub!(:should_succeed?).and_return(true)
      @guest.prepare_sms_invitation!(Time.now.utc)
      @guest.sms_invitation_sent_at.should_not be_nil
      @guest.sms_invitation_failed_at.should be_nil
    end
  end

  describe "send email invitation" do
    before(:each) do
      @guest = Factory.create(:guest)
    end

    it "should update email_invitation_sent_at and email_token" do
      @guest.email_invitation_sent_at.should be_nil
      @guest.email_token.should be_nil
      t = Time.now.utc
      @guest.prepare_email_invitation!(t)
      @guest.email_invitation_sent_at.should == t
      @guest.email_token.should_not be_nil
    end

    it "should not change email_token" do
      @guest.email_token = "foobar"
      @guest.save

      @guest.prepare_email_invitation!(Time.now.utc)
      @guest.email_token.should == "foobar"
    end
  end
end
