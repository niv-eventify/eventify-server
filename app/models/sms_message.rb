class SmsMessage < ActiveRecord::Base
  belongs_to :guest, :counter_cache => :sms_messages_count
  belongs_to :event, :counter_cache => :sms_messages_count
  attr_accessible :all

  before_validation_on_create :set_event

  validates_presence_of :guest_id, :event_id, :receiver_mobile, :message, :sender_mobile

  MAX_LENGTH = 140

  def set_event
    if guest
      self.event_id = guest.event_id
      self.receiver_mobile = guest.mobile_phone
      self.sender_mobile = event.host_mobile_number if event
    end
  end

  def send_sms!
    sms = Cellact::Sender.new(SMS_FROM, SMS_USER, SMS_PASSWORD, sender_mobile)

    res = sms.send_sms(receiver_mobile, message) do |flow|
      flow.request do |dump|
        self.request_dump = dump
        save!
      end
      flow.response do |dump, exception, is_sent|
        self.response_dump = dump || exception
        self.sent_at = Time.now.utc unless exception
        self.success = is_sent
        save!
      end
    end
  end
end
