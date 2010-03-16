class Reminder < ActiveRecord::Base
  belongs_to :event
  has_many :reminder_logs

  BEFORE_UNITS  = ActiveSupport::OrderedHash.new do |h|
    h["hours"]  = N_("Hours")
    h["days"]   = N_("Days")
    h["months"] = N_("Months")
  end

  attr_accessible :to_yes, :to_no, :to_may_be, :to_not_responded, :by_email, :by_sms, 
    :email_subject, :email_body, :sms_message, :before_units, :before_value

  named_scope :pending, :conditions => ["reminders.reminder_sent_at IS NULL AND reminders.send_reminder_at > ?", Time.now.utc]
  named_scope :with_event, :include => :event

  before_validation :set_send_date
  def set_send_date
    self.before_units = BEFORE_UNITS.keys.member?(before_units) ? before_units : "days"
    self.send_reminder_at = event.starting_at - (before_value || 0).to_i.send(before_units)
  end

  validates_presence_of :before_units, :before_value
  validates_presence_of :email_subject, :email_body, :if => :by_email?
  validates_length_of   :email_subject, :within => 2..255, :if => :by_email?
  validates_length_of   :email_body, :within => 2..255, :if => :by_email?
  validates_presence_of :sms_message, :if => :by_sms

  def validate
    errors.add(:before_value, _("should be in a future")) if reminder_sent_at.nil?  && (!send_reminder_at || send_reminder_at >= event.starting_at)
    errors.add(:by_email, s_("...mail or sms|choose a delivery method")) if !by_email? && !by_sms?
    errors.add(:to_yes, s_("can't be blank")) if !to_yes? && !to_no? && !to_may_be? && !to_not_responded?
  end

  def self.send_reminders
    log.info "\n\nsending reminders\n\n"
    pending.with_event.find_each(:batch_size => 1) do |reminder|
      reminder.reminder_sent_at = Time.now.utc
      reminder.save!
      reminder.send_remindersd_later(:deliver!)
    end
  end

  def deliver!
    _deliver_by_email! if by_email?
    _deliver_by_sms!   if by_sms?
  end
protected

  def _deliver_by_email!
    event.guests.to_be_reminded_by(self).find_each(:batch_size => 1) do |guest|
       # TODO: deliver email, create reminder log
    end
  end

  def _deliver_by_sms!
    event.guests.to_be_reminded_by(self).find_each(:batch_size => 1) do |guest|
       # TODO: deliver sms, create reminder log
    end
  end
end
