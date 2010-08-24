require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Guest do

  describe "filling in contacts" do
    before(:each) do
      @event = Factory.create(:event)
      @event.user.contacts.count.should be_zero
    end

    it "should create a contact when adding a new guest" do
      @event.guests.create(:name => "foo", :email => "foo@bar.com")
      @event.user.contacts.first.email.should == "foo@bar.com"
    end

    it "should set a suggested name when contact already exists" do
      @event.user.contacts.create(:name => "FOOBAR", :email => "foo@bar.com")
      lambda { 
        g = @event.guests.create(:name => "foo", :email => "foo@bar.com")
        g.suggested_name.should == "FOOBAR"
      }.should_not change(Contact, :count)
    end
  end

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
      @guest.any_invitation_sent.should be_false
    end

    it "should reset sms_invitation_sent_at when mobile_phone is changed" do
      @guest.mobile_phone = "0541234567"
      @guest.save.should be_true
      @guest.sms_invitation_sent_at.should be_nil
      @guest.any_invitation_sent.should be_false
    end

    it "should not reset email_invitation_sent_at when phone number is changed" do
      @guest.mobile_phone = "0541234567"
      @guest.save.should be_true
      @guest.email_invitation_sent_at.should_not be_nil
      @guest.any_invitation_sent.should be_false
    end

    it "should reset sms_invitation_sent_at when email is changed" do
      @guest.email = "changed@email.com"
      @guest.save.should be_true
      @guest.sms_invitation_sent_at.should_not be_nil
      @guest.any_invitation_sent.should be_false
    end

    it "should not reset any_invitation_sent" do
      @guest.any_invitation_sent = true
      @guest.name = "foo bar"
      @guest.save.should be_true
      @guest.any_invitation_sent.should be_true
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
    end
    it "should be ready to send sms invitation next day" do

      @guest.event.delay_sms_sending = true
      t = (Time.now.utc.beginning_of_day + 23.hours).in_time_zone("Jerusalem")
      at_time(t) do
        @guest.event.send_invitations
        @guest.reload.send_sms_invitation_at.should == t.beginning_of_day + 10.hours
      end
    end

    it "should not send sms invitaions next day" do
      @guest.event.delay_sms_sending = false
      t = (Time.now.utc.beginning_of_day + 23.hours).in_time_zone("Jerusalem")
      at_time(t) do
        @guest.event.send_invitations
        @guest.reload.send_sms_invitation_at.should == t
      end
    end
  end

  describe "send sms invitation" do
    before(:each) do
      @guest = Factory.create(:guest_with_mobile)
    end

    describe "scheduling" do
      it "should schedule sending" do
        @guest.send_sms_invitation_at = 1.minute.ago
        @guest.save!

        g = Guest.scheduled_to_invite_by_sms_overdue
        g.size.should == 1
        g.first.id.should == @guest.id
      end

      it "cron should do nothing" do
        @guest.send_sms_invitation_at = 1.day.from_now
        @guest.save!

        Guest.should_not_receive(:mass_prepare_sms)
        Guest.delayed_sms_cron_job
      end

      it "cron should prepare sms" do
        @guest.send_sms_invitation_at = 1.day.ago
        @guest.save!

        Guest.should_receive(:mass_prepare_sms) do |array|
          array.count.should == 1
          array.first.id.should == @guest.id
          # mock functionality
          @guest.send_sms_invitation_at = nil
          @guest.save
        end
        Guest.delayed_sms_cron_job        
      end
    end
    
    describe "sending" do
      before(:each) do
        @guest.event.send_invitations
        @guest.reload.sms_invitation_sent_at.should be_nil
        @guest.sms_invitation_failed_at.should be_nil
        @guest.send_sms_invitation_at.should_not be_nil
      end

      it "should reset sent at" do
        @guest.delayed_sms_resend = false
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
        @guest.delayed_sms_resend = false
        @guest.prepare_sms_invitation!
        @guest.sms_invitation_sent_at.should_not be_nil
        @guest.sms_invitation_failed_at.should be_nil
      end
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
      @guest.should_receive(:send_later).with(:send_summary_status)
      @guest.save!
      @guest.summary_email_sent_at.should_not be_nil
    end
  end

  describe "bounces" do
    it "should clear unbounce" do
      @guest = Factory.create(:guest_with_bounce)
      @guest.bounced_at.should_not be_nil

      @guest.email = "another@q.com"
      @guest.save
      @guest.bounced_at.should be_nil
    end

    it "should bounce" do
      @guest = Factory.create(:guest)
      @guest.bounced_at.should be_nil
      @guest.bounce!("foo", "bar")
      @guest.bounced_at.should_not be_nil
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
      @guest.prepare_email_invitation!(false)
      @guest.email_invitation_sent_at.should == @send_at
      @guest.send_email_invitation_at.should be_nil
      @guest.email_token.should_not be_nil
    end

    it "should not change email_token" do
      @guest.email_token = "foobar"
      @guest.save

      @guest.prepare_email_invitation!(false)
      @guest.email_token.should == "foobar"
    end
  end

  describe "reminders" do
    before(:each) do
      @guest = Factory.build(:guest)
      @reminder = Reminder.new
      reminder_logs = mock("reminder_logs")
      reminder_logs.stub!(:create)
      @reminder.stub!(:reminder_logs).and_return(reminder_logs)
    end

    it "should not send if not invited" do
      Notifier.should_not_receive(:deliver_guest_reminder)
      @guest.send_reminder!(@reminder)
    end

    describe "delivery" do
      before(:each) do
        @guest.stub!(:invited?).and_return(true)
      end

      describe "email" do
        before(:each) do
          @reminder.by_email = true
        end

        it "should send by email when invitation is by email" do
          @guest.send_email = true
          Notifier.should_receive(:deliver_guest_reminder)
          @guest.send_reminder!(@reminder)
        end

        it "should not send by email if invitation is not by email" do
          @guest.send_email = false
          Notifier.should_not_receive(:deliver_guest_reminder)
          @guest.send_reminder!(@reminder)
        end
      end

      describe "sms" do
        before(:each) do
          @reminder.by_sms = true
          @sms_messages = mock("sms_messages")
          sms = mock("sms")
          sms.stub!(:send_sms!)
          sms.stub!(:success?)
          @sms_messages.stub!(:create!).and_return(sms)
          @guest.stub!(:sms_messages).and_return(@sms_messages)
        end

        it "should send by sms when invitation is by sms" do
          @guest.send_sms = true
          @sms_messages.should_receive(:create!)
          @guest.send_reminder!(@reminder)
        end

        it "should not send by sms when invitation is not by sms" do
          @guest.send_sms = false
          @sms_messages.should_not_receive(:create!)
          @guest.send_reminder!(@reminder)
        end
      end
    end

  end
end
