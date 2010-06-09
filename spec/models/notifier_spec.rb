require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Notifier do
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @guest = Factory.create(:guest_with_token)
  end

  after(:each) do
    Notifier.deliveries.last.to_s.should =~ /#{@guest.name}/
  end

  [:he, :en].each do |locale|
    I18n.with_locale(locale) do

      it "should send summary email in #{locale}" do
        Notifier.deliver_guests_summary(@guest.event, {2 => [@guest.to_rsvp_email_params]}, 10.day.ago)
      end      

      it "should send invite_resend_guest with locale #{locale}" do
        Notifier.deliver_invite_resend_guest(@guest)
      end

      it "should send invite_guest with locale #{locale}" do
        Notifier.deliver_invite_guest(@guest)
      end

      it "should send guest_reminder with locale #{locale}" do
        Notifier.deliver_guest_reminder(@guest, "subject", "message")
      end

      it "should send taking_removed with locale #{locale}" do
        Notifier.deliver_taking_removed(@guest, Thing.new(:name => "some"))
      end
    end
  end
end