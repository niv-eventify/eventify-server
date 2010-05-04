class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :design

  has_many :hosts
  accepts_nested_attributes_for :hosts, :allow_destroy => true

  accepts_nested_attributes_for :user
  validates_associated :user, :if => proc { |e| e.user.activated_at.blank? }

  has_many :guests
  has_many :things do
    def total_amount
      calculate(:sum, :amount)
    end

    def total_amount_picked
      calculate(:sum, :amount_picked)
    end
  end
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
    }
  attr_accessible :map
  validates_attachment_size :map, :less_than => 10.megabytes

  attr_accessible :category_id, :design_id, :name, :starting_at, :ending_at, 
    :location_name, :location_address, :map_link, :guest_message, :category, :design
    

  datetime_select_accessible :starting_at, :ending_at

  validates_presence_of :category_id, :design_id, :name, :starting_at
  validates_length_of :guest_message, :maximum => 345, :allow_nil => true, :allow_blank => true
  validates_format_of :map_link,
    :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix,
    :allow_nil => true, :allow_blank => true, :live_validator => /|/

  # sms sending validations
  attr_accessor :send_invitations_now
  attr_accessible :send_invitations_now, :sms_message, :host_mobile_number
  validates_presence_of :host_mobile_number, :on => :update, :if => :going_to_send_sms?
  validates_format_of   :host_mobile_number, :with => String::PHONE_REGEX, :on => :update, :if => :going_to_send_sms?
  validates_presence_of :sms_message, :on => :update, :if => :going_to_send_sms?
  validates_length_of   :sms_message, :maximum => 140, :allow_nil => true, :allow_blank => true, :on => :update, :if => :going_to_send_sms?

  def going_to_send_sms?
    should_send_sms? && send_invitations_now
  end

  after_update :check_send_invitations
  def check_send_invitations
    send_invitations if send_invitations_now
  end

  after_create :create_default_reminder
  def create_default_reminder
    opts = Reminder::DEFAULT_REMINDER.clone
    opts[:email_subject] = s_(opts[:email_subject])
    opts[:email_body] = s_(opts[:email_body])
    reminders.create(opts)
  end

  after_update :adjust_reminders
  def adjust_reminders
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

  before_create :set_stage_passed
  def set_stage_passed
    self.stage_passed = 2
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

  def send_invitations
    "production" == Rails.env ? send_later(:delayed_send_invitations) : delayed_send_invitations
  end

  def validate
    errors.add(:starting_at, _("should be in a future")) if starting_at && starting_at < Time.now.utc
    errors.add(:base, _("Payments are not completed yet")) if send_invitations_now && payment_required?
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

  def scoped_invite(scope, method, timestamp)
    scope.find_each(:batch_size => 10) { |obj| obj.send(method, timestamp) }
  end

  def delayed_send_invitations
    time_stamp = Time.now.utc
    Event.transaction do
      self.last_invitation_sent_at = time_stamp
      send_sms_invitations(time_stamp)
      send_email_invitations(time_stamp)
      self.send_invitations_now = nil
      save!
    end
  end

  def send_sms_invitations(timestamp)
    scoped_invite(guests.not_invited_by_sms.with_ids(guest_ids), :prepare_sms_invitation!, timestamp)
  end

  def send_email_invitations(timestamp)
    scoped_invite(guests.not_invited_by_email.with_ids(guest_ids), :prepare_email_invitation!, timestamp)
  end

  def cancel_sms!
    _cancel_sms_invitations!
    _cancel_sms_reminders!
  end

  def default_sms_message
    _("You've been invited to %{event_name}") % {:event_name => name}
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

protected

  def _cancel_sms_reminders!
    reminders.update_all("by_sms = 0")
    reminders.update_all("is_active = 0", "by_sms = 0 AND by_email = 0")
  end

  def _cancel_sms_invitations!
    guests.update_all("send_sms = 0")
  end
end
