require File.dirname(__FILE__) + '/../spec_helper'

describe Event do

  describe "validations" do
    before(:each) do
      @event = Event.new
      @event.user = User.new
    end

    it "should validate starting and ending at" do
      @event.starting_at = 2.days.from_now
      @event.ending_at = 1.day.from_now
      @event.should_not be_valid
      @event.errors.on(:ending_at).should == "should be in a future"
    end
  end

  describe "best_time_to_send_sms" do
    before(:each) do
      @event = Factory.create(:event_with_tz)
      # check daylight save time
      t = Time.utc(2010, 6, 8, 11, 0)
      t.in_time_zone("Jerusalem").hour.should == 14
    end

    it "should suggest to send now when delay is disabled" do
      at_time(Time.utc(2010, 6, 8, 11, 0)) do
        @event.best_time_to_send_invitation_sms(false).should == Time.utc(2010, 6, 8, 11, 0)
      end
    end

    it "should suggest to send now if delay is enabled" do
      at_time(Time.utc(2010, 6, 8, 11, 0)) do
        @event.best_time_to_send_invitation_sms(true).should == Time.utc(2010, 6, 8, 11, 0)
      end
    end

    it "should suggest to send later today if delay is enabled and too early" do
      t = Time.utc(2010, 8, 6, 1, 0)
      t.in_time_zone("Jerusalem").hour.should == 4
      t.in_time_zone("Jerusalem").day.should == 6

      at_time(t) do
        @event.best_time_to_send_invitation_sms(true).should == Time.utc(2010, 8, 6, 7, 0)
      end
    end

    it "should suggest to send tomorrow if delay is enabled and too late" do
      t = Time.utc(2010, 8, 6, 19, 0)
      t.in_time_zone("Jerusalem").hour.should == 22
      t.in_time_zone("Jerusalem").day.should == 6

      at_time(t) do
        @event.best_time_to_send_invitation_sms(true).should == Time.utc(2010, 8, 7, 7, 0)
      end
    end
  end

  describe "stage passed" do
    it "should set stage_passed to 4 when sending invitations" do
      event = Factory.create(:event)
      event.stage_passed.should_not == 3
      event.should_receive(:send_later).with(:delayed_send_invitations)
      event.send_invitations
      event.stage_passed.should == 4
      event.any_invitation_sent.should be_true
    end
  end

  describe "resend invitations" do
    before(:each) do
      @event = Factory.create(:event)
    end

    [:starting_at, :location_address, :location_name].each do |a|
      it "should want to resend invitations when #{a} is changed" do
        @event.should_not be_should_resend_invitations
        @event.send(a).is_a?(String) ? @event.send("#{a}=", "new value") : @event.send("#{a}=", 10.days.ago)
        @event.should be_details_for_resend_invitations_changed
      end
    end
  end

  context "summary" do
    describe "summary timer reset" do
      before(:each) do
        @event = Factory.create(:event_with_daily_summary_never_sent)
        @event.rsvp_summary_send_at.should be_nil
      end

      it "should reset summary timer when next sending timer is blank" do
        @event.rsvp_summary_send_every = 3
        @event.save!
        @event.rsvp_summary_send_at.should == @event.created_at
      end

      it "should not reset summary timer when next sending timer is not blank" do
        t = 1.day.ago.utc
        @event.rsvp_summary_send_every = 3
        @event.rsvp_summary_send_at = t
        @event.save!
        @event.rsvp_summary_send_at.should == t
      end

      it "should not reset summary timer if schedule is not changed" do
        @event.save!
        @event.rsvp_summary_send_at.should be_nil
      end
    end

    describe "creating new event" do
      before(:each) do
        @event = Factory.create(:event)
      end

      it "should create a default email reminder" do
        @event.reminders.count.should == 1
        @event.reminders.first.by_email.should be_true
        @event.reminders.first.by_sms.should_not be_true
      end

      it "should have ical" do
        @event.to_ical.should =~ /#{@event.name}/
      end
    end

    describe "default sms message" do
      before(:each) do
        @event = Factory.create(:event)
      end

      it "should include location when event has location name" do
        @event.location_name = "location_name"
        @event.default_sms_message.should =~ /location_name/
        @event.default_sms_message_for_resend.should =~ /location_name/
      end

      it "should include location when event has location address" do
        @event.location_address = "location_address"
        @event.default_sms_message.should =~ /location_address/
        @event.default_sms_message_for_resend.should =~ /location_address/
      end

      it "should include location when event has location address and name" do
        @event.location_name = "location_name"
        @event.location_address = "location_address"
        @event.default_sms_message.should =~ /location_address/
        @event.default_sms_message.should =~ /location_name/
        @event.default_sms_message_for_resend.should =~ /location_address/
        @event.default_sms_message_for_resend.should =~ /location_name/
      end

      it "should not include location when no location" do
        @event.location_name = nil
        @event.location_address = nil
        t = @event.with_time_zone{@event.starting_at.to_s(:isra_time)}
        @event.default_sms_message.should =~ /#{t}\. Invite sent to your email\. #{@event.user.name}/
        @event.default_sms_message_for_resend.should =~ /#{t}\. Invite sent to your email\. #{@event.user.name}/
      end

      it "should not include location when location is too long" do
        @event.location_name = "long" * 40
        @event.location_address = nil
        @event.location.should == "long" * 40
        t = @event.with_time_zone{@event.starting_at.to_s(:isra_time)}
        @event.default_sms_message.should =~ /#{t}\. #{@event.user.name}/
        @event.default_sms_message_for_resend.should =~ /#{t}\. #{@event.user.name}/
      end
    end

    describe "sending email" do
      before(:each) do
        @event = Factory.create(:event)
      end

      it "should not send email when no new guests" do
        @event.stub!(:guests_for_this_summary!).and_return([0, {}])
        Notifier.should_not_receive :deliver_guests_summary
        @event.send_summary_email!
      end

      it "should send new email when new guests list is not empty" do
        @event.stub!(:guests_for_this_summary!).and_return([1, {}])
        Notifier.should_receive :deliver_guests_summary
        @event.send_summary_email!
      end
    end

    describe "finding new guests" do
      it "should find new guest" do
        g = Factory.create(:guest_summary_not_sent)
        guests_count, rsvps = g.event.guests_for_this_summary!
        guests_count.should == 1
        rsvps.should == {0 => [], 1 => [{:name => "New Guest", :email => "new@guest.com", :mobile_phone => "0501234567"}], 2 => []}
      end
    end

    describe "updates" do
      before(:each) do
        @event = Factory.create(:event_with_daily_summary)
      end

      it "should set 24hrs delay for sending next summary email" do
        at_time(Time.now.utc) do
          @event.update_next_summary_send!
          @event.rsvp_summary_send_at.should == 24.hours.from_now.utc
        end
      end

      it "should set 7 days delay for sending next summary email" do
        at_time(Time.now.utc) do
          @event.rsvp_summary_send_every = 3
          @event.update_next_summary_send!
          @event.rsvp_summary_send_at.should == 7.days.from_now.utc
        end
      end

      describe "close event" do
        it "should disable rsvps by setting next sent after the event datetime" do
          at_time(Time.now.utc) do
            @event.starting_at = 20.minutes.from_now
            @event.update_next_summary_send!
            @event.rsvp_summary_send_at.should == (20*60 + 1).seconds.from_now
          end
        end

        it "should set 1 minute delay for sending rsvps" do
          at_time(Time.now.utc) do
            @event.starting_at = 61.minutes.from_now
            @event.update_next_summary_send!
            @event.rsvp_summary_send_at.should == 1.minute.from_now.utc
          end
        end
      end
    end
  end

  describe "activated user event checks" do
    describe "invitations" do
      it "should send if event is active" do
        event = Factory.create(:event)
        event.should_receive(:send_later).with(:delayed_send_invitations)
        event.send_invitations
      end

      it "should not send if event is inactive" do
        event = Factory.create(:inactive_event)
        event.should_not_receive(:send_later).with(:delayed_send_invitations)
        event.send_invitations        
      end
    end

    describe "reminders" do
      it "should send if event is active" do
        @event = Factory.build(:event)
        @original_start = 2.days.from_now.utc
        @event.starting_at = @original_start
        @event.save!
        @reminder = @event.reminders.create!(:before_units => "days", :before_value => 1, :by_sms => true, :sms_message => "some")        
        @reminder.reminder_sent_at.should be_nil
        at_time(Time.now) do
          Time.now = 1.day.from_now + 12.hours
          Reminder.send_reminders
          @reminder.reload.reminder_sent_at.should_not be_nil
        end
      end

      it "should not send if event is inactive" do
        @event = Factory.build(:inactive_event)
        @original_start = 2.days.from_now.utc
        @event.starting_at = @original_start
        @event.save!
        @reminder = @event.reminders.create!(:before_units => "days", :before_value => 1, :by_sms => true, :sms_message => "some")        
        @reminder.reminder_sent_at.should be_nil
        at_time(Time.now) do
          Time.now = 1.day.from_now + 12.hours
          Reminder.send_reminders
          @reminder.reload.reminder_sent_at.should be_nil
        end        
      end
    end

    describe "summary emails" do
      it "should send summary email if event is active" do
        @event = Factory.create(:event)
        @event.rsvp_summary_send_every = 2
        @event.rsvp_summary_send_at = 1.day.ago
        @event.save(false)
        Event.next_event_to_send_summary.id.should == @event.id
      end
      
      it "should not send summary email if event is inactive" do
        @event = Factory.create(:inactive_event)
        @event.rsvp_summary_send_every = 2
        @event.rsvp_summary_send_at = 1.day.ago
        @event.save!
        Event.next_event_to_send_summary.should be_nil
      end
    end
  end

  describe "sms sending validations" do
    before(:each) do
      @event = Factory.create(:event)
    end

    describe "not sending sms" do      
      before(:each) do
        @event.stub!(:should_send_sms?).and_return(false)
        @event.stub!(:should_resend_sms?).and_return(false)
        @event.send_invitations_now = true
      end

      it "should be valid" do
        @event.should be_valid
      end
    end

    describe "re sending sms" do
      it "should not validate host mobile" do
        @event.host_mobile_number = "junk"
        @event.should be_valid
        @event.errors.on(:host_mobile_number).should be_blank
      end

      describe "validations" do
        before(:each) do
          @event.stub!(:should_resend_sms?).and_return(true)
          @event.send_invitations_now = true
          @event.should_not be_valid
        end

        it "validate sms_message" do
          @event.errors.on(:sms_resend_message).should_not be_blank
          @event.errors.on(:sms_message).should be_blank
        end

        it "validate host mobile" do
          @event.errors.on(:host_mobile_number).should_not be_blank
        end
      end
    end

    describe "sending sms" do
      it "should not validate host mobile" do
        @event.host_mobile_number = "junk"
        @event.should be_valid
        @event.errors.on(:host_mobile_number).should be_blank
      end

      describe "validations" do
        before(:each) do
          @event.stub!(:should_send_sms?).and_return(true)
          @event.send_invitations_now = true
          @event.should_not be_valid
        end

        it "validate sms_message" do
          @event.errors.on(:sms_message).should_not be_blank
          @event.errors.on(:sms_resend_message).should be_blank
        end

        it "validate host mobile" do
          @event.errors.on(:host_mobile_number).should_not be_blank
        end
      end
    end
  end
end
