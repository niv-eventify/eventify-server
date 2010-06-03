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

  has_many :reminders

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
    :msg_color, :title_color, :font, :allow_seeing_other_guests, :tz
    

  datetime_select_accessible :starting_at, :ending_at

  validates_presence_of :category_id, :design_id, :name, :starting_at
  validates_length_of :guest_message, :maximum => 345, :allow_nil => true, :allow_blank => true
  validates_format_of :map_link,
    :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix,
    :allow_nil => true, :allow_blank => true, :live_validator => /|/

  # sms sending validations
  attr_accessor :send_invitations_now
  attr_accessor :delay_sms_sending
  attr_accessible :sms_message, :host_mobile_number, :delay_sms_sending
  validates_presence_of :host_mobile_number, :on => :update, :if => :going_to_send_sms?
  validates_phone_number :host_mobile_number, :if => :going_to_send_sms?, :on => :update
  validates_presence_of :sms_message, :on => :update, :if => :going_to_send_sms?
  validates_length_of   :sms_message, :maximum => SmsMessage::MAX_LENGTH, :allow_nil => true, :allow_blank => true, :on => :update, :if => :going_to_send_sms?

  def going_to_send_sms?
    should_send_sms? && send_invitations_now
  end

  after_update :check_send_invitations
  def check_send_invitations
    send_invitations if send_invitations_now
  end

  # after_validation_on_update :check_resend_invitations
  # def check_resend_invitations
  #   if starting_at_changed? || location_name_changed? || location_address_changed?
  # end

  after_create :create_default_reminder
  def create_default_reminder
    opts = Reminder::DEFAULT_REMINDER.clone
    opts[:email_subject] = s_(opts[:email_subject])
    opts[:email_body] = s_(opts[:email_body])
    reminders.create(opts)
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

  named_scope :upcoming, lambda{{:conditions => ["events.starting_at > ?", Time.now.utc]}}
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

    @invitations_to_send_counts = {
      :email => e,
      :sms => s,
      :total => (e + s)
    }
  end

  def payments
    [] # TODO association with payment history
  end

  def payment_required?
    require_payment_for_guests? || require_payment_for_sms?
  end

  def allow_delayed_sms?
    Event.best_time_to_send_sms < starting_at
  end

  def self.best_time_to_send_sms
    1.day.from_now.utc.beginning_of_day + 10.hours
  end

  def send_invitations
    return unless user_is_activated?

    Event.transaction do
      self.send_invitations_now = nil
      self.stage_passed = 4
      self.any_invitation_sent = true
      save!

      guests.not_invited_by_email.update_all ["send_email_invitation_at = ?", Time.now.utc]

      sms_at = (delay_sms_sending && allow_delayed_sms?) ? Event.best_time_to_send_sms : Time.now.utc
      guests.not_invited_by_sms.update_all ["send_sms_invitation_at = ?", sms_at]

      send_later(:send_sms_invitations)
      send_later(:send_email_invitations)
    end
  end

  def validate
    errors.add(:starting_at, _("should be in a future")) if starting_at && starting_at < Time.now.utc
    errors.add(:base, _("Payments are not completed yet")) if send_invitations_now && payment_required?
    errors.add(:starting_at, _("time cannot be blank")) if @no_time_selected
  end

  def has_map?
    !map_link.blank? || (map && !map.url.blank?)
  end

  def allow_send_invitations?
    true # TODO: payments logic
  end

  def require_payment_for_guests?
    false # TODO: check max number/program and existing payment in payments table
  end

  def should_send_sms?
    !guests.not_invited_by_sms.count.zero?
    # TODO: also check reminders
  end

  def require_payment_for_sms?
    false 
    # should_send_sms? && sms_package_ok? # TODO: check sms payments in payments table
  end

  def scoped_invite(scope, method)
    scope.find_each(:batch_size => 10) { |obj| obj.send(method) }
  end

  def send_sms_invitations
    scoped_invite(guests.scheduled_to_invite_by_sms.with_ids(guest_ids), :prepare_sms_invitation!)
  end

  def send_email_invitations
    scoped_invite(guests.scheduled_to_invite_by_email.with_ids(guest_ids), :prepare_email_invitation!)
  end

  def cancel_sms!
    _cancel_sms_invitations!
    _cancel_sms_reminders!
  end

  def default_sms_message
    with_time_zone do
      opts = {
        :event_name => name, 
        :host_name => user.name,
        :date => starting_at.to_s(:isra_date),
        :time => starting_at.to_s(:isra_time),
        :location => (location.blank? ? "" : (_("at location %{location}") % {:location => location}))
      }
      s = _("%{event_name} on %{date} at %{time}%{location}. Invite sent to your email. %{host_name}") % opts
      return s if s.length < SmsMessage::MAX_LENGTH # check sms length

      _("%{event_name} on %{date} at %{time}. %{host_name}") % opts
    end
  end

  def location
    [location_name, location_address].compact_blanks.join(", ")
  end

  def to_ical
    ie = returning(Icalendar::Event.new) do |e|
      e.dtstart = starting_at.to_datetime
      e.summary = name
      e.dtend = ending_at.to_datetime if ending_at
      e.description = guest_message unless guest_message.blank?
      e.uid = "eventify-#{id}"
      e.location = location unless location.blank?
    end
    c = Icalendar::Calendar.new
    c.prodid = "eventify-0.0.1"
    c.add_event(ie)
    c.to_ical
  end

  def ical_filename
    "eventify-#{id}.ics"
  end

  def invitation_email_subject
    _("%{host_name}'s %{event_name} event") % {:host_name => user.name, :event_name => name}
  end

  def self.default_start_time
    2.weeks.from_now.beginning_of_day + 11.hours
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

protected

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
