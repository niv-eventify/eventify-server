require File.dirname(__FILE__) + '/../spec_helper'

describe Reminder do

  describe "scope" do
    it "should generate future scope" do
      t = Time.now.utc
      t.stub!(:utc).and_return(t)
      Time.stub!(:now).and_return(t)
      Reminder.pending.proxy_options.should == {:conditions=>["reminders.reminder_sent_at IS NULL AND reminders.send_reminder_at <= ?", t]}

      t = 10.minutes.from_now
      t.stub!(:utc).and_return(t)
      Time.stub!(:now).and_return(t)
      Reminder.pending.proxy_options.should == {:conditions=>["reminders.reminder_sent_at IS NULL AND reminders.send_reminder_at <= ?", t]}
    end
  end

  describe "validations" do
    before(:each) do
      @event = Factory.create(:event)
      @reminder = @event.reminders.build
      @reminder.before_value = @reminder.before_units = nil # skip defaults for new form
    end

    it "should validate presense of before_units/before_value" do
      @reminder.should_not be_valid
      @reminder.errors.on(:before_units).should be_blank
      @reminder.before_units.should == "days"
      @reminder.errors.on(:before_value).should_not be_blank
    end

    it "should validate presence of delivery method" do
      @reminder.should_not be_valid
      @reminder.errors.on(:by_email).should_not be_blank      
    end

    it "should validate presence of send_reminder_at" do
      @reminder.before_units = "days"
      @reminder.before_value = -2
      @reminder.should_not be_valid
      @reminder.send_reminder_at.to_i.should == (@event.starting_at + 2.days).to_i
      @reminder.errors.on(:before_value).should =~ /should be in a future/
    end

    it "should validate if sending by email" do
      @reminder.by_email = true
      @reminder.should_not be_valid
      @reminder.errors.on(:email_subject).should_not be_blank
      @reminder.errors.on(:email_body).should_not be_blank
      @reminder.errors.on(:sms_message).should be_blank
    end

    it "should validate if sending by sms" do
      @reminder.by_sms = true
      @reminder.should_not be_valid
      @reminder.errors.on(:email_subject).should be_blank
      @reminder.errors.on(:email_body).should be_blank
      @reminder.errors.on(:sms_message).should_not be_blank
    end
  end

  describe "remove reminders" do
    before(:each) do
      @event = Factory.create(:event)
      @reminder = @event.reminders.create!(:before_units => "hours", :before_value => 1, :by_sms => true, :sms_message => "some")
    end

    it "should destroy not sent reminder" do
      @reminder.destroy.should be_true
      @reminder.errors.should be_blank
    end

    it "should not destroy sent reminder" do
      @reminder.reminder_sent_at = Time.now.utc
      @reminder.save
      @reminder.destroy.should_not be_true
      @reminder.errors.should_not be_blank      
    end
  end

  describe "rescheduing events" do
    before(:each) do
      @event = Factory.build(:event)
      @original_start = 11.days.from_now.utc
      @event.starting_at = @original_start
      @event.save!
      @reminder = @event.reminders.create!(:before_units => "hours", :before_value => 1, :by_sms => true, :sms_message => "some")
    end

    it "should be active reminder" do
      @reminder.should be_is_active
    end

    it "should have reminder_send_at date" do
      @reminder.send_reminder_at.to_i.should == (@original_start - 1.hour).to_i
    end

    it "should reschedule reminder" do
      @event.starting_at = @original_start - 2.hours
      @event.save!
      @reminder.reload.send_reminder_at.to_i.should == (@original_start - 3.hours).to_i
      @reminder.should be_is_active
    end

    it "should deactivate reminder" do
      @event.starting_at = 1.minute.from_now
      @event.save!
      @reminder.reload.should_not be_is_active
    end
  end

  describe "should create healthy reminders" do
    before(:each) do
      @event = Factory.create(:event)
    end
  
    [:by_email, :by_sms].each do |by|
      it "should create when sending #{by}" do
        opts = {
          :before_units => "days", :before_value => 2,
        }
        if :by_sms == by
          opts[:sms_message] = "body body body"
        else
          opts[:email_body] = "body body body"
          opts[:email_subject] = "subject subject subject"
        end
        opts[by] = true

        @reminder = @event.reminders.create(opts)
        @reminder.should_not be_new_record
      end
    end
  end
end
