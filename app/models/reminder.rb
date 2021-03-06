class Reminder < ActiveRecord::Base
  belongs_to :event
  has_many :reminder_logs

  def self.default_before_units
    return @default_before_units if @default_before_units

    @default_before_units ||= ActiveSupport::OrderedHash.new
    @default_before_units["hours"]  = N_("Hours")
    @default_before_units["days"]   = N_("Days")
    @default_before_units["weeks"] =  N_("Weeks")
    @default_before_units["months"] = N_("Months")

    @default_before_units
  end

  attr_accessible :by_email, :by_sms, :before_units, :before_value, :is_active

  named_scope :pending, lambda {{:conditions => ["reminders.reminder_sent_at IS NULL AND reminders.send_reminder_at <= ?", Time.now.utc]}}
  named_scope :outstanding, lambda {{:conditions => ["reminders.reminder_sent_at IS NULL AND reminders.send_reminder_at > ?", Time.now.utc]}}
  named_scope :active, :conditions => {:is_active => true}
  named_scope :not_sent, {:conditions => "reminders.reminder_sent_at IS NULL"}
  named_scope :with_activated_event, :include => :event, :conditions => "events.user_is_activated = '1' AND events.canceled_at is NULL"
  named_scope :by_sms, :conditions => {:by_sms => true}

  before_validation :set_before_units
  def set_before_units
    self.before_units = self.class.default_before_units.keys.member?(before_units) ? before_units : "days"
  end
  before_validation :set_sending_time
  def set_sending_time
    self.send_reminder_at = best_time_to_send_reminder(event.starting_at - (before_value || 1).to_i.send(before_units))
  end

  def best_time_to_send_reminder(t)
    new_sending_time = Astrails.best_time_to_send_sms(t, event.tz)
    new_sending_time = t if new_sending_time >= event.starting_at
    new_sending_time
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
  validates_uniqueness_of :by_email, :scope => [:before_units, :before_value, :event_id], :message => _("An email reminder for this exact time has already been created."), :if => :by_email

  validates_uniqueness_of :by_sms, :scope => [:before_units, :before_value, :event_id], :message => _("An SMS reminder for this exact time has already been created."), :if => :by_sms
  def validate
    errors.add(:before_value, _("should be in a future")) if active_not_yet_sent? && (send_reminder_at.blank? || in_past?)
    errors.add(:by_email, s_("mail or sms - choose a delivery method")) if !by_email? && !by_sms?
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
    loop do
      reminders = active.pending.with_activated_event.find(:all, :limit => 10)
      break if reminders.blank?

      logger.info "\n\n#{Time.now.utc.to_s(:db)} sending reminders - found reminders, ids = #{reminders.collect(&:id).inspect}"

      Reminder.update_all(["reminder_sent_at = ?", Time.now.utc], ["reminders.id in (?)", reminders.collect(&:id)])
      reminders.each {|reminder| reminder.deliver! }
    end
  end

  def deliver!
    logger.info "#{Time.now.utc.to_s(:db)} deliver! reminder_id=#{self.id}\n"
    event.guests.find_each(:batch_size => 1) do |guest|
      guest.delay.send_reminder!(self)
    end
  end

  def email_subject
    _("Reminder: %{event_name}") % {:event_name => event.name}
  end

  def email_body
    event.default_reminder_message
  end

  def sms_message
    _("Reminder: %{default_sms}") % {:default_sms => event.default_sms_message}
  end

  def set_default_values
    return unless event

    self.attributes = {
      :by_sms => false,
      :by_email => true,
      :before_units => "days",
      :before_value => 1
    }
  end
end
