require File.dirname(__FILE__) + '/../spec_helper'

describe Reminder do
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

    it "should validate presence of rsvp conditions" do
      @reminder.should_not be_valid
      @reminder.errors.on(:to_yes).should_not be_blank      
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

  describe "should create healthy reminders" do
    before(:each) do
      @event = Factory.create(:event)
    end
  
    [:to_yes, :to_no, :to_may_be, :to_not_responded].each do |whom_to|
      [:by_email, :by_sms].each do |by|
        it "should create when sending #{whom_to} #{by}" do
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
          opts[whom_to] = true

          @reminder = @event.reminders.create(opts)
          @reminder.should_not be_new_record
        end
      end
    end
  end
end
