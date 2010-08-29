class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :design

  has_many :hosts
  accepts_nested_attributes_for :hosts, :allow_destroy => true

  accepts_nested_attributes_for :user
  validates_associated :user, :if => proc { |e| e.user.activated_at.blank? }

  DEFAULT_TIME_ZONE = "Jerusalem"

  has_many :guests do
    def import(new_guests)
      guests_imported = 0

      new_guests.each do |g|
        guest = build(:name => g["name"], :email => g["email"], :mobile_phone => g["mobile"])
        guest.send_email = true unless guest.email.blank?
        guests_imported += 1 if guest.save
      end

      guests_imported
    end

    def invited_stats
      e = invited_by_email.count
      s = invited_by_sms.count
      {:email => e, :sms => s, :total => (e + s)}
    end
  end
  has_many :things do
    def total_amount
      calculate(:sum, :amount)
    end

    def total_amount_picked
      calculate(:sum, :amount_picked)
    end
  end
  has_many :takings

  has_many :reminders do
    def upcoming_by_sms_count
      active.pending.with_activated_event.by_sms.count
    end
  end

  has_many :sms_messages

  include Event::Summary

  has_attached_file :map,
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket) || "junk",
    :path =>        "/maps/:id/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url => ':s3_domain_url'
  attr_accessible :map
  validates_attachment_size :map, :less_than => 10.megabytes

  attr_accessible :category_id, :design_id, :name, :starting_at, :ending_at, 
    :location_name, :location_address, :map_link, :guest_message, :category, :design, :msg_font_size, :title_font_size, :msg_text_align, :title_text_align,
    :msg_color, :title_color, :font_title, :font_body, :allow_seeing_other_guests, :tz,
    :cancellation_sms, :cancellation_email, :cancellation_email_subject

  datetime_select_accessible :starting_at, :ending_at

  validates_presence_of :category_id, :design_id, :name, :starting_at
  validates_length_of :guest_message, :maximum => 345, :allow_nil => true, :allow_blank => true
  validates_format_of :map_link,
    :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix,
    :allow_nil => true, :allow_blank => true, :live_validator => /|/

  # sms sending validations
  attr_accessor :send_invitations_now, :delay_sms_sending, :resend_invitations
  attr_accessible :sms_message, :sms_resend_message, :host_mobile_number, :delay_sms_sending, :resend_invitations,
    :cancel_by_email, :cancel_by_sms
  validates_presence_of :host_mobile_number, :on => :update, :if => :going_to_send_or_resend_sms?
  validates_phone_number :host_mobile_number, :if => :going_to_send_or_resend_sms?, :on => :update

  validates_presence_of   :sms_message, :on => :update, :if => :going_to_send_sms?
  validates_sms_length_of :sms_message, :on => :update, :if => :going_to_send_sms?

  validates_presence_of   :sms_resend_message, :on => :update, :if => :going_to_resend_sms?
  validates_sms_length_of :sms_resend_message, :on => :update, :if => :going_to_resend_sms?

  validates_presence_of :cancellation_sms, :on => :update, :if => :cancel_by_sms?
  validates_presence_of :cancellation_email, :cancellation_email_subject, :on => :update, :if => :cancel_by_email?

  def going_to_send_or_resend_sms?
    going_to_send_sms? || going_to_resend_sms?
  end

  def going_to_send_sms?
    should_send_sms? && send_invitations_now
  end

  def going_to_resend_sms?
    should_resend_sms? && send_invitations_now
  end

  after_update :check_send_invitations
  def check_send_invitations
    send_invitations if send_invitations_now
  end

  def resend_invitations=(value)
    @resend_invitations = ("true" == value)
  end

  after_validation_on_update :check_resend_invitations
  def check_resend_invitations
    self.stage_passed = 3 if should_resend_invitations?
  end

  after_update :check_reset_invitation_status
  def check_reset_invitation_status
    guests.invited_or_scheduled.update_all("sms_invitation_sent_at = NULL, email_invitation_sent_at = NULL") if should_resend_invitations?
  end

  def should_resend_invitations?
    resend_invitations && any_invitation_sent? && details_for_resend_invitations_changed?
  end

  def details_for_resend_invitations_changed?
    starting_at_changed? || location_address_changed? || location_name_changed?
  end

  after_create :create_default_reminder
  def create_default_reminder
    r = reminders.build
    r.set_default_values
    r.save
  end

  after_update :adjust_reminders
  def adjust_reminders
    return unless starting_at_changed?
    disabled = reminders.not_sent.collect(&:adjust!)
    @reminders_disabled = disabled.any?
  end

  def reminders_disabled?
    @reminders_disabled
  end

  def send_cancellation
    return true unless going_to_send_cancellation?
    self.cancellation_sent_at = Time.now.utc
    # TODO return false when not enough money to proceed with sms
    save!
    send_later(:send_cancellation!)
    true
  end

  named_scope :upcoming, lambda{{:conditions => ["events.canceled_at IS NULL AND events.starting_at > ?", Time.now.utc]}}
  named_scope :cancelled, {:conditions => "canceled_at is not null"}
  named_scope :past, lambda{{:conditions => ["events.starting_at < ?", Time.now.utc]}}
  named_scope :with, lambda {|*with_associations| {:include => with_associations} }
  named_scope :by_starting_at, :order => "events.starting_at ASC"

  before_create :set_initial_stage
  def set_initial_stage
    self.stage_passed = 2
  end

  before_create :set_default_time_zone
  def set_default_time_zone
    self.tz ||= DEFAULT_TIME_ZONE
  end

  def invitations_to_send_counts
    return @invitations_to_send_counts if @invitations_to_send_counts

    e, s = guests.not_invited_by_email.count, guests.not_invited_by_sms.count
    e_resend, s_resend = guests.not_invited_by_email.any_invitation_sent.count, guests.not_invited_by_sms.any_invitation_sent.count

    @invitations_to_send_counts = {
      :email => e - e_resend,
      :sms => s - s_resend,
      :total => (e + s),
      :resend_email => e_resend,
      :resend_sms => s_resend
    }
  end

  def allow_delayed_sms?
    best_time_to_send_invitation_sms(true) < starting_at
  end

  def best_time_to_send_invitation_sms(allow_delay)
    allow_delay ? Astrails.best_time_to_send_sms(Time.now.utc, tz) : Time.now.utc
  end

  def send_invitations
    return unless user_is_activated?

    Event.transaction do
      self.send_invitations_now = nil
      self.stage_passed = 4
      self.any_invitation_sent = true
      save!

      guests.not_invited_by_email.update_all ["send_email_invitation_at = ?", Time.now.utc]

      sms_at = best_time_to_send_invitation_sms(delay_sms_sending && allow_delayed_sms?)
      guests.not_invited_by_sms.update_all ["send_sms_invitation_at = ?", sms_at]

      send_later(:delayed_send_invitations)
    end
  end

  def validate
    errors.add(:starting_at, _("start date should be in a future")) if starting_at && starting_at < Time.now.utc
    errors.add(:starting_at, _("time cannot be blank")) if @no_time_selected
    errors.add(:ending_at, _("end date should be in a future")) if starting_at && ending_at && ending_at < starting_at
  end

  def has_map?
    !map_link.blank? || (map && !map.url.blank?)
  end

  def should_resend_sms?
    !guests.any_invitation_sent.not_invited_by_sms.count.zero?
  end

  def should_send_sms?
    !guests.no_invitation_sent.not_invited_by_sms.count.zero?
    # TODO: also check reminders
  end

  def delayed_send_invitations
    guests.find_each(:batch_size => 10) do |g|
      resend = g.any_invitation_sent?

      g.prepare_email_invitation!(resend) if g.scheduled_to_invite_by_email?

      # sms inviations are sent form Guets#delayed_sms_cron_job
      if g.scheduled_to_invite_by_sms?
        g.delayed_sms_resend = resend
        g.save!
      end
    end
  end

  def cancel_sms!
    _cancel_sms_invitations!
    _cancel_sms_reminders!
  end

  def default_sms_message_for_resend
    with_time_zone do
      opts = {
        :event_name => name,
        :host_name => user.name,
        :date => starting_at.to_s(:isra_date),
        :time => starting_at.to_s(:isra_time),
        :location => (location.blank? ? "" : " " + location)
      }
      s = _("Changes: %{event_name} on %{date} at %{time}%{location}. Invite sent to your email. %{host_name}") % opts
      return s if s.mb_chars.length < SmsMessage::MAX_LENGTH # check sms length

      _("Changes: %{event_name} on %{date} at %{time}. %{host_name}") % opts
    end
  end

  def default_reminder_message
    with_time_zone do
      opts = {
        :event_name => name, 
        :host_name => user.name,
        :date => starting_at.to_s(:isra_date),
        :time => starting_at.to_s(:isra_time),
        :location => (location.blank? ? "" : " " + location),
      }
      s = _("Reminder:%{event_name} on %{date} at %{time}%{location}.%{host_name}") % opts
      return s if s.mb_chars.length < SmsMessage::MAX_LENGTH # check sms length

      _("Reminder:%{event_name} on %{date} at %{time}.%{host_name}") % opts
    end
  end

  def default_sms_message
    with_time_zone do
      opts = {
        :event_name => name, 
        :host_name => user.name,
        :date => starting_at.to_s(:isra_date),
        :time => starting_at.to_s(:isra_time),
        :location => (location.blank? ? "" : " " + location)
      }
      s = _("%{event_name} on %{date} at %{time}%{location}. Invite sent to your email. %{host_name}") % opts
      return s if s.mb_chars.length < SmsMessage::MAX_LENGTH # check sms length

      s = _("%{event_name} on %{date} at %{time}%{location}. %{host_name}") % opts
      return s if s.mb_chars.length < SmsMessage::MAX_LENGTH # check sms length

      _("%{event_name} on %{date} at %{time}. %{host_name}") % opts
    end
  end

  def location
    [location_name, location_address].compact_blanks.join(", ")
  end

  def to_ical(convert = false)
    ie = with_time_zone do
      returning(Icalendar::Event.new) do |e|
        e.dtstart = starting_at.to_datetime
        e.summary = name
        e.dtend = ending_at.to_datetime if ending_at
        e.description = guest_message unless guest_message.blank?
        e.uid = "eventify-#{id}"
        e.location = location unless location.blank?
        e.organizer = "CHANGEME"
        e.tzid = tz
      end
    end
    c = Icalendar::Calendar.new
    c.prodid = nil
    c.version = nil
    c.add_event(ie)
    res = c.to_ical.gsub("\r", "")
    res.gsub!("ORGANIZER:CHANGEME", "ORGANIZER;CN=#{user.name}:MAILTO:#{user.email}")
    # TODO: autodetect encoding
    convert ? Iconv.iconv("windows-1255", "UTF-8", res).to_s : res
  end

  def ical_filename(convert = false)
    "eventify-#{id}.#{convert ? "vcs" : "ics"}"
  end

  def invitation_email_subject
    _("%{host_name}'s %{event_name} event") % {:host_name => user.name, :event_name => name}
  end

  def self.default_start_time
    Event.new.with_time_zone do
      1.hour.ago.change(:sec => 0, :min => 0)
    end
  end

  def with_time_zone(default_time_zone = DEFAULT_TIME_ZONE)
    old_tz = Time.zone
    begin
      ::Time.zone = tz || default_time_zone || old_tz
      yield
    ensure
      ::Time.zone = old_tz
    end
  end

  def delay_sms_sending=(value)
    if value.is_a?(String)
      @delay_sms_sending = ("true" == value)
    else
      @delay_sms_sending = value
    end
  end

  def past?
    starting_at < Time.now.utc
  end

  def bounce_guest_by_email!(email, status, reason)
    guest = guests.find_by_email(email)
    return unless guests

    guest.bounce!(status, reason)
  end


  def bounced_emails_count
    @bounced_emails_count ||= guests.bounced.count
  end

  def cancel!
    _cancel_pending_invitations!
    # summary will be disabled automatically
    _disable_reminders!

    self.canceled_at = Time.now.utc
    save!
  end

  def canceled?
    canceled_at
  end

  def cancellation_sent?
    !cancellation_sent_at.nil?
  end

  def changes_allowed?
    !(canceled? || past?)
  end

  def going_to_send_cancellation?
    cancel_by_email? || cancel_by_sms?
  end

  def send_cancellation!
    if cancel_by_email?
      guests.invited_by_email.find_each(:batch_size => 1) do |g|
        g.cancellation_email_sent_at = Time.now.utc
        g.save!
        g.send_cancellation_email(self.cancellation_email_subject, self.cancellation_email)
      end
    end

    if cancel_by_sms?
      guests.invited_by_sms.find_each(:batch_size => 1) do |g|
        g.cancellation_sms_sent_at = Time.now.utc
        g.save!
        g.send_cancellation_sms(self.cancellation_sms)
      end
    end
  end

  def set_cancellations(invited_stats)
    self.cancel_by_sms = !invited_stats[:sms].zero?
    self.cancel_by_email = !invited_stats[:email].zero?
    self.cancellation_sms = cancel_sms_default_text
    self.cancellation_email = cancel_email_default_text
    self.cancellation_email_subject = cancel_email_default_subject
  end

  def cancel_sms_default_text
    _("Sorry, %{event_name} has been cancelled") % { :event_name => name }
  end

  def cancel_email_default_text
    _("Hi,\n\n%{event_name} has been cancelled.\n\n%{host_name}") % {
      :event_name => name, :host_name => user.name
    }
  end

  def cancel_email_default_subject
    _("Cancelled: %{event_name}") % { :event_name => name }
  end

  def payments_required?
    guests_payments_required? || sms_payments_required? || prints_payments_required?
  end

  def prints_payments_required?
    prints_ordered > prints_plan
  end

  def guests_payments_required?
    guests.count > emails_plan
  end

  def sms_payments_required?
    total_sms_count > sms_plan
  end

  def total_sms_count
    invitations_to_be_sent = guests.scheduled_to_invite_by_sms.count + guests.not_invited_by_sms.count

    messagess_sent = sms_messages.count

    reminders_to_be_sent = reminders.upcoming_by_sms_count * guests.invite_by_sms.count

    invitations_to_be_sent + messagess_sent + reminders_to_be_sent
  end

protected

  def _cancel_pending_invitations!
    guests.scheduled_to_invite_by_sms.update_all("send_sms_invitation_at = NULL")
    # emails should already be sent
  end

  def _disable_reminders!
    reminders.update_all("is_active = 0")
  end

  def _cancel_sms_reminders!
    reminders.update_all("by_sms = 0")
    reminders.update_all("is_active = 0", "by_sms = 0 AND by_email = 0")
  end

  def _cancel_sms_invitations!
    guests.update_all("send_sms = 0")
  end

private
  def instantiate_time_object(name, values)
    if "starting_at" == name && 3 == values.size
      # no time selected
      @no_time_selected = true
    end

    if self.class.send(:create_time_zone_conversion_attribute?, name, column_for_attribute(name))
      Time.zone.local(*values)
    else
      Time.time_with_datetime_fallback(@@default_timezone, *values)
    end
  end
end
