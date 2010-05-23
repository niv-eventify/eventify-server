class Reminder < ActiveRecord::Base
  belongs_to :event
  has_many :reminder_logs

  DEFAULT_REMINDER = {
    :before_units => "days",
    :before_value => 1,
    :by_email => true,
    :email_subject => N_("This is default reminder subject text - change me"),
    :email_body => N_("This is default reminder body text - change me"),
  }

  def self.default_before_units
    return @default_before_units if @default_before_units

    @default_before_units ||= ActiveSupport::OrderedHash.new
    @default_before_units["hours"]  = N_("Hours")
    @default_before_units["days"]   = N_("Days")
    @default_before_units["weeks"] =  N_("Weeks")
    @default_before_units["months"] = N_("Months")

    @default_before_units
  end

  attr_accessible :by_email, :by_sms, :email_subject, :email_body, :sms_message, :before_units, :before_value, :is_active

  named_scope :pending, lambda {{:conditions => ["reminders.reminder_sent_at IS NULL AND reminders.send_reminder_at <= ?", Time.now.utc]}}
  named_scope :active, :conditions => {:is_active => true}
  named_scope :not_sent, {:conditions => "reminders.reminder_sent_at IS NULL"}
  named_scope :with_activated_event, :include => :event, :conditions => "events.user_is_activated = 1"

  before_validation :set_before_units
  def set_before_units
    self.before_units = self.class.default_before_units.keys.member?(before_units) ? before_units : "days"
  end
  before_validation :set_sending_time
  def set_sending_time
    self.send_reminder_at = event.starting_at - (before_value || 0).to_i.send(before_units)
  end

  def adjust!
    res = false

    set_sending_time
    begin
      save!
    rescue ActiveRecord::RecordInvalid
      self.is_active = false
      res = self.is_active_changed?
      save!
    end

    res
  end

  validates_presence_of :before_units, :before_value
  validates_presence_of :email_subject, :email_body, :if => :by_email?
  validates_length_of   :email_subject, :within => 2..255, :if => :by_email?
  validates_length_of   :email_body, :within => 2..255, :if => :by_email?
  validates_presence_of :sms_message, :if => :by_sms

  def validate
    errors.add(:before_value, _("should be in a future")) if active_not_yet_sent? && (send_reminder_at.blank? || in_past?)
    errors.add(:by_email, s_("...mail or sms|choose a delivery method")) if !by_email? && !by_sms?
  end

  def before_destroy
    unless reminder_sent_at.nil?
      errors.add(:base, "already sent")
      return false
    end
  end

  def active_not_yet_sent?
    reminder_sent_at.nil? && is_active?
  end

  def in_past?
    send_reminder_at >= event.starting_at || Time.now.utc > send_reminder_at
  end

  def initialize(params = nil)
    super
    self.before_value ||= 7
    self.before_units ||= "days"
  end

  def before_in_words
    case before_units
    when "hours"
      n_("One hour before the event", "%d hours before the event", before_value) % before_value
    when "days"
      n_("One day before the event", "%d days before the event", before_value) % before_value
    when "weeks"
      n_("One week before the event", "%d weeks before the event", before_value) % before_value
    when "months"
      n_("One month before the event", "%d months before the event", before_value) % before_value
    end
  end

  def by_in_words
    returning([]) do |res|
      res << s_("reminder send by|by Email") if by_email?
      res << s_("reminder send by|by SMS") if by_sms?
    end.join(", ")
  end

  def self.send_reminders
    logger.info "\n\nsending reminders\n\n"

    loop do
      reminders = active.pending.with_activated_event.find(:all, :limit => 100)
      break if reminders.blank?

      Reminder.update_all(["reminder_sent_at = ?", Time.now.utc], ["reminders.id in (?)", reminders.collect(&:id)])
      reminders.each do |reminder|
        logger.info "\n\nsend_later(:deliver!) reminder_id=#{reminder.id}\n\n"
        reminder.send_later(:deliver!)
      end      
    end
  end

  def deliver!
    logger.info "\n\ndeliver! reminder_id=#{self.id}\n\n"
    event.guests.find_each(:batch_size => 1) do |guest|
      guest.send_later(:send_reminder!, self)
    end
  end
end
