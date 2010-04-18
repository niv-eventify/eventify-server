class Guest < ActiveRecord::Base
  belongs_to :event
  has_many :cellact_logs, :as => :cellactable

  validates_presence_of :name

  validates_format_of   :email, :with => String::EMAIL_REGEX, :message => N_("does't look like an email"), :allow_blank => true, :allow_nil => true
  validates_presence_of :email, :if => proc {|guest| guest.send_email?}
  validates_uniqueness_of :email, :scope => :event_id, :allow_nil => true, :allow_blank => true, :on => :create

  validates_format_of   :mobile_phone, :with => String::PHONE_REGEX, :message => N_("does't look like a mobile phone number"), :allow_blank => true, :allow_nil => true
  validates_presence_of :mobile_phone, :if => proc {|guest| guest.send_sms?}
  validates_uniqueness_of :mobile_phone, :scope => :event_id, :allow_nil => true, :allow_blank => true

  attr_accessible :name, :email, :mobile_phone, :send_email, :send_sms, :allow_snow_ball, :attendees_count, :rsvp

  named_scope :invite_by_sms, {:conditions => {:send_sms => true}}
  named_scope :invite_by_email, {:conditions => {:send_email => true}}

  named_scope :not_invited_by_sms, {:conditions => "guests.sms_invitation_sent_at IS NULL AND guests.send_sms = 1"}
  named_scope :sms_invitation_failed, {:conditions => "guests.sms_invitation_failed_at IS NOT NULL"}
  named_scope :not_invited_by_email, {:conditions => "guests.email_invitation_sent_at IS NULL AND guests.send_email = 1"}
  named_scope :with_ids, lambda {|ids| {:conditions => ["guests.id in (?)", ids]}}
  named_scope :summary_email_not_sent, :conditions => "guests.summary_email_sent_at IS NULL"

  after_create :increase_stage_passed
  after_update :check_invitation_failures # TODO -smth is wrong here
  before_update :update_summary_status
  after_update :send_summary_status

  RSVP_TEXT = [N_("No"), N_("Yes"), N_("May Be")]

  def increase_stage_passed
    if 2 == event.stage_passed.to_i
      event.stage_passed = 3
      event.save
    end
  end

  def update_summary_status
    if rsvp_changed?
      self.summary_email_sent_at = event.immediately_send_rsvp? ? Time.now.utc : nil
    end
  end

  def send_summary_status
    if rsvp_changed? && event.immediately_send_rsvp?
      rsvps = {rsvp => [to_rsvp_email_params]}
      Notifier.send_later(:deliver_guests_summary, event, rsvps, nil)
    end
  end

  def to_rsvp_email_params
    {:name => name, :email => email, :mobile_phone => mobile_phone}
  end

  def reset_summary_status!
    self.summary_email_sent_at = Time.now.utc
    save!
  end

  def prepare_sms_invitation!(timestamp)
    # TODO = check sms bulk status / package payments
    self.sms_invitation_sent_at = timestamp
    save!
    "production" == Rails.env ? self.send_later(:send_sms_invitation!) : send_sms_invitation!
  end

  def send_sms_invitation!
    sms = Cellact::Sender.new(SMS_FROM, SMS_USER, SMS_PASSWORD, event.host_mobile_number)
    unless sms.send_sms(mobile_phone, event.sms_message, self)
      self.sms_invitation_failed_at = Time.now.utc
      save!
    end
  end

  def prepare_email_invitation!(timestamp)
    self.email_token ||= Astrails.generate_token
    self.email_invitation_sent_at = timestamp
    save!
    "production" == Rails.env ? self.send_later(:send_email_invitation!) : send_email_invitation!
  end

  def send_email_invitation!
    I18n.with_locale(event.language) { Notifier.deliver_invite_guest(self) }
  end

  def send_reminder!(reminder)
    return unless invited?

    if reminder.by_email?
      # TODO: handle delivery errors
      Notifier.deliver_guest_reminder(self, reminder.email_subject, reminder.email_body)
      reminder.reminder_logs.create(:guest_id => self.id, :destination => email, :message => "#{reminder.email_subject}/#{reminder.email_body}", :status => "success", :kind => "email")
    end

    if reminder.by_sms?
      sms = Cellact::Sender.new(SMS_FROM, SMS_USER, SMS_PASSWORD, event.host_mobile_number)
      status = sms.send_sms(mobile_phone, reminder.sms_message, self) ? "success" : "failure"
      reminder.reminder_logs.create(:guest_id => self.id, :destination => mobile_phone, :message => reminder.sms_message, :status => status, :kind => "sms")
    end
  end

  def before_destroy
    return false if invited?
  end

  def invited?
    email_invitation_sent_at || sms_invitation_sent_at
  end

  def email_recipient
    "#{name} <#{email}>"
  end

  def check_invitation_failures
    # reset sms errors when mobile phone changed
    if send_sms? && !sms_invitation_failed_at.nil? && mobile_phone_changed?
      self.sms_invitation_sent_at = self.sms_invitation_failed_at = nil
    end
  end
end
