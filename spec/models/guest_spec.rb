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

  describe "stage statuses" do
    before(:each) do
      @event = Factory.create(:event)
      @event.stage_passed.should == 2
    end

    it "should set stage to 3 when a guest created" do
      guest = @event.guests.create(:name => "foobar", :email => "foo@bar.com", :send_email => true)
      guest.should_not be_new_record
      @event.reload.stage_passed = 3
    end

    describe "with sent invitations" do
      before(:each) do
        @event.stage_passed = 4
        @event.save(false)
      end

      it "should reset stage passed when new guest added" do
        guest = @event.guests.create(:name => "foobar", :email => "foo@bar.com", :send_email => true)
        @event.reload.stage_passed = 3
      end

      it "should reset stage passed when guest should receive a new invitation" do
        guest = @event.guests.create(:name => "foobar", :email => "foo@bar.com", :send_email => true)
        @event.stage_passed = 4
        @event.save(false)
        guest.email = "bar@foo.com"
        guest.save.should be_true
        @event.reload.stage_passed.should == 3
      end
    end
  end

  describe "updates" do
    before(:each) do
      @guest = Factory.create(:guest_without_email_and_phone)
      @guest.send_sms.should be_nil
      @guest.send_email.should be_nil
    end

    it "should not change send_sms when mobile added" do
      @guest.mobile_phone = "0123456789"
      @guest.save.should be_true
      @guest.send_sms.should_not be_true
    end

    it "should change send_email when email added" do
      @guest.email = "email@email.com"
      @guest.save.should be_true
      @guest.send_email.should be_true
    end

  end

  describe "invitation sent statuses" do
    before(:each) do
      @guest = Factory.create(:guest_with_sent_inviations)
      @guest.email_invitation_sent_at.should_not be_nil
      @guest.sms_invitation_sent_at.should_not be_nil
      @guest.send_sms_invitation_at.should be_nil
      @guest.send_email_invitation_at.should be_nil
    end

    after(:each) do
      @guest.send_sms_invitation_at.should be_nil
      @guest.send_email_invitation_at.should be_nil
    end

    it "should reset email_invitation_sent_at when email is changed" do
      @guest.email = "changed@email.com"
      @guest.save.should be_true
      @guest.email_invitation_sent_at.should be_nil
    end

    it "should reset sms_invitation_sent_at when mobile_phone is changed" do
      @guest.mobile_phone = "0541234567"
      @guest.save.should be_true
      @guest.sms_invitation_sent_at.should be_nil
    end

    it "should not reset email_invitation_sent_at when phone number is changed" do
      @guest.mobile_phone = "0541234567"
      @guest.save.should be_true
      @guest.email_invitation_sent_at.should_not be_nil
    end

    it "should reset sms_invitation_sent_at when email is changed" do
      @guest.email = "changed@email.com"
      @guest.save.should be_true
      @guest.sms_invitation_sent_at.should_not be_nil
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

  describe "delayed sms" do
    before(:each) do
      @guest = Factory.create(:guest_with_mobile)
      @guest.event.delay_sms_sending = true
      @guest.event.send_invitations
    end

    it "should be ready to send sms invitation next day" do
      @guest.reload.send_sms_invitation_at.should == (Time.now.utc + 1.day).beginning_of_day + 10.hours
    end
  end

  describe "send sms invitation" do
    before(:each) do
      @guest = Factory.create(:guest_with_mobile)
      @guest.event.send_invitations
      @guest.reload.sms_invitation_sent_at.should be_nil
      @guest.reload.sms_invitation_failed_at.should be_nil
      @guest.reload.send_sms_invitation_at.should_not be_nil
    end

    it "should reset sent at" do
      @guest.prepare_sms_invitation!
      @guest.sms_invitation_sent_at.should_not be_nil
      @guest.send_sms_invitation_at.should be_nil
    end

    it "should save failure time" do
      @guest.send_sms_invitation!
      @guest.sms_invitation_failed_at.should_not be_nil
    end

    it "should send sms" do
      Cellact::Sender.stub!(:should_succeed?).and_return(true)
      @guest.prepare_sms_invitation!
      @guest.sms_invitation_sent_at.should_not be_nil
      @guest.sms_invitation_failed_at.should be_nil
    end
  end

  describe "summary status" do
    before(:each) do
      @guest = Factory.create(:guest)
      @summary_email_sent_at = @guest.summary_email_sent_at
    end

    it "should not change summary_email_sent_at when rsvp is not changed" do
      @guest.name = "foo bar"
      @guest.save!
      @guest.summary_email_sent_at.should == @summary_email_sent_at
    end

    it "should change summary_email_sent_at when rsvp is changed" do
      @guest.rsvp = 2
      Notifier.should_not_receive :send_later
      @guest.save!
      @guest.summary_email_sent_at.should be_nil      
    end

    it "should not reset when need to send rsvp immediately" do
      @guest.event.stub!(:immediately_send_rsvp?).and_return(true)
      @guest.rsvp = 2
      Notifier.should_receive(:send_later).with(:deliver_guests_summary, @guest.event, {2 => [@guest.to_rsvp_email_params]}, nil)
      @guest.save!
      @guest.summary_email_sent_at.should_not be_nil
    end
  end

  describe "send email invitation" do
    before(:each) do
      @guest = Factory.create(:guest)
      @guest.event.send_invitations
      @send_at = @guest.reload.send_email_invitation_at
      @send_at.should_not be_nil
    end

    it "should update email_invitation_sent_at and email_token" do
      @guest.email_invitation_sent_at.should be_nil
      @guest.email_token.should be_nil
      @guest.prepare_email_invitation!
      @guest.email_invitation_sent_at.should == @send_at
      @guest.send_email_invitation_at.should be_nil
      @guest.email_token.should_not be_nil
    end

    it "should not change email_token" do
      @guest.email_token = "foobar"
      @guest.save

      @guest.prepare_email_invitation!
      @guest.email_token.should == "foobar"
    end
  end
end
