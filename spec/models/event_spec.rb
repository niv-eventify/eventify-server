require File.dirname(__FILE__) + '/../spec_helper'

describe Event do
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
        rsvps.should == {0 => [], 1 => [{:name => "New Guest", :email => "new@guest.com", :mobile_phone => "012345678"}], 2 => []}
      end
    end

    describe "updates" do
      before(:each) do
        @event = Factory.create(:event_with_daily_summary)
      end

      it "should set 24hrs delay for sending next summary email" do
        t = stub_time
        @event.update_next_summary_send!
        @event.rsvp_summary_send_at.should == 24.hours.from_now.utc
      end

      it "should set 7 days delay for sending next summary email" do
        t = stub_time
        @event.rsvp_summary_send_every = 3
        @event.update_next_summary_send!
        @event.rsvp_summary_send_at.should == 7.days.from_now.utc
      end

      describe "close event" do
        it "should disable rsvps by setting next sent after the event datetime" do
          t = stub_time
          @event.starting_at = 20.minutes.from_now
          @event.update_next_summary_send!
          @event.rsvp_summary_send_at.should == (20*60 + 1).seconds.from_now
        end

        it "should set 1 minute delay for sending rsvps" do
          t = stub_time
          @event.starting_at = 61.minutes.from_now
          @event.update_next_summary_send!
          @event.rsvp_summary_send_at.should == 1.minute.from_now.utc
        end
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
        @event.send_invitations_now = true
      end

      it "should be valid" do
        @event.should be_valid
      end
    end

    describe "sending sms" do      
      before(:each) do
        @event.stub!(:should_send_sms?).and_return(true)
        @event.send_invitations_now = true
      end

      describe "validations" do
        before(:each) do
          @event.should_not be_valid
        end

        it "validate sms_message" do
          @event.errors.on(:sms_message).should_not be_blank
        end

        it "validate host mobile" do
          @event.errors.on(:host_mobile_number).should_not be_blank
        end
      end
    end
  end
end
