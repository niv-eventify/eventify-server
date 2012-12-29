class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :design

  has_many :backgrounds
  has_many :hosts
  accepts_nested_attributes_for :hosts, :allow_destroy => true

  accepts_nested_attributes_for :user
  attr_accessible :user_attributes
  validates_associated :user, :on => :create, :if => proc { |e| e.user.activated_at.blank? }

  DEFAULT_TIME_ZONE = "Jerusalem"
  RATIO = 1.6 #fullsize/preview_size

  has_many :guests do
    def import(new_guests, save_as_contact)
      guests_imported = 0
      new_guests.each do |g|
        guest = build(:name => g["name"], :email => g["email"], :mobile_phone => g["mobile"], :save_as_contact => save_as_contact)
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
      active.outstanding.with_activated_event.by_sms.count
    end
  end

  has_many :sms_messages
  has_many :payments
  has_many :payment_attempts, :through => :payments
  has_many :cropped_pictures
  has_many :guests_messages

  include Event::Summary

  has_attached_file :map,
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket) || "junk",
    :path =>        "maps/:id/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url => ':s3_domain_url'
  attr_accessible :map
  validates_attachment_size :map, :less_than => 2.megabytes, :message => _("File size should be less than %{max_file_size}MB") % {:max_file_size => 2}

  attr_accessible :category_id, :design_id, :name, :starting_at, :ending_at,
    :location_name, :location_address, :map_link, :invitation_title, :guest_message, :category, :design, :msg_font_size, :title_font_size, :msg_text_align, :title_text_align,
    :msg_color, :title_color, :font_title, :text_top_x, :text_top_y, :text_width, :text_height,
    :title_top_x, :title_top_y, :title_width, :title_height, :font_body, :allow_seeing_other_guests, :tz,
    :cancellation_sms, :cancellation_email, :cancellation_email_subject

  has_attached_file :invitation_thumb,
    :storage        => :s3,
    :bucket         => GlobalPreference.get(:s3_bucket) || "junk",
    :styles         => {:original => "900x600", :small => "176x117>"},
    :path =>        "invitation_thumbs/:id/:style/:filename",
    :default_url   => "",
    :s3_credentials => {
      :access_key_id     => GlobalPreference.get(:s3_key) || "junk",
      :secret_access_key => GlobalPreference.get(:s3_secret) || "junk",
    },
    :url => ':s3_domain_url'

  datetime_select_accessible :starting_at, :ending_at

  validates_presence_of :category_id, :design_id, :name, :starting_at
  validates_length_of :invitation_title, :maximum => 1024, :allow_nil => true, :allow_blank => true
  validates_length_of :guest_message, :maximum => 1024, :allow_nil => true, :allow_blank => true

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

  before_create :set_default_summary
  def set_default_summary
    self.rsvp_summary_send_at = self.created_at if self.rsvp_summary_send_at.nil? #default summary is once per day
  end

  after_update :adjust_reminders
  def adjust_reminders
    return unless starting_at_changed?
    disabled = reminders.not_sent.collect(&:adjust!)
    @reminders_disabled = disabled.any?
  end

  def set_invitation_thumbnail
    return unless id > 0
    self.delay.set_invitation_thumbnail!
  end

  def set_invitation_thumbnail!
    bottom_pics = [] #[url,geometry]
    self.cropped_pictures.find_all_by_window_id(design.windows).each do |cp|
      window = cp.window
      bottom_pics << [cp.pic.url, "#{window.width}x#{window.height}+#{window.top_x}+#{window.top_y}"]
    end
    return if bottom_pics.blank?
    logger.info("set_invitation_thumbnail! - event id: #{self.id}, bottom_pics: #{bottom_pics}")
    res = ImageMerger::merge_two_images(design.card.url, bottom_pics, design.card_file_name)
    self.invitation_thumb = res
    self.save
  end

  def remove_invitation_thumbnail
    self.delay.remove_invitation_thumbnail!
  end

  def remove_invitation_thumbnail!
    self.invitation_thumb = nil
    self.save
  end

  before_save :set_http_in_map_link
  def set_http_in_map_link
    if !map_link.blank? && map_link[/\A(http)/].nil?
      map_link.insert(0,"http://")
    end
  end

  def reminders_disabled?
    @reminders_disabled
  end

  def send_cancellation
    return true unless going_to_send_cancellation?
    self.cancellation_sent_at = Time.now.utc
    # TODO return false when not enough money to proceed with sms
    save!
    self.delay.send_cancellation!
    true
  end

  named_scope :upcoming, lambda{{:conditions => ["events.canceled_at IS NULL AND events.starting_at > ?", Time.now.utc]}}
  named_scope :cancelled, {:conditions => "canceled_at is not null"}
  named_scope :past, lambda{{:conditions => ["events.starting_at < ?", Time.now.utc]}}
  named_scope :with, lambda {|*with_associations| {:include => with_associations} }
  named_scope :by_starting_at, :order => "events.starting_at ASC"
  named_scope :by_created_at, :order => "events.created_at DESC"
  named_scope :by_user_id, lambda{|user_id|
    user = User.find(user_id)
    {:conditions => ["events.id IN (SELECT event_id FROM hosts WHERE hosts.email = ?) OR events.id IN (SELECT id FROM events WHERE user_id = ?)", user.email, user.id]}
  }
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

      self.delay.delayed_send_invitations
    end
  end

  def validate
    errors.add(:starting_at, _("start date should be in a future")) if starting_at && starting_at < Time.now.utc
    errors.add(:starting_at, _("time cannot be blank")) if @no_time_selected
    errors.add(:ending_at, _("end date should be in a future")) if starting_at && ending_at && ending_at < starting_at
  end

  def has_map?
    !map_link.blank? || has_image_map?
  end

  def has_image_map?
    map && !map.url.blank?
  end

  def has_movie?
    !Movie.find_by_event_id(self.id).nil?
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
        g.prepare_sms_invitation!
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
    _("Hi,%{event_name} has been cancelled.%{host_name}") % {
      :event_name => name, :host_name => user.name
    }
  end

  def cancel_email_default_subject
    _("Cancelled: %{event_name}") % { :event_name => name }
  end

  def is_premium?
    #TODO: when there are premium design with no designer change this method
    return design.is_premium?
  end

  def is_paid_for_invitations?
    payments = Payment.find_all_by_event_id(self.id)
    res = false
    payments.each{|p| res = res || (!p.paid_at.nil? && p.pay_emails > 0)}
    return res
  end

  def payments_required?
    return false if user.is_free? && !self.is_premium?

    guests_payments_required? || sms_payments_required? || prints_payments_required?
  end

  def prints_payments_required?
    prints_ordered > prints_plan
  end

  def guests_payments_required?
    guests.invite_by_email.count > emails_plan
  end

  def sms_payments_required?
    total_sms_count > sms_plan
  end

  def total_invitations_count
    @total_invitations_count ||= guests.invite_by_email.count
  end

  def total_sms_count
    return @total_sms_count if @total_sms_count

    if canceled?
      # already recieved sms invitation are the same guests we're going to send cancellation text
      @total_sms_count = guests.invited_by_sms.count * 2
    else
      invitations_to_be_sent = guests.scheduled_to_invite_by_sms.count + guests.not_invited_by_sms.count

      messagess_sent = sms_messages.count

      reminders_to_be_sent = reminders.upcoming_by_sms_count * guests.invite_by_sms.count

      @total_sms_count = invitations_to_be_sent + messagess_sent + reminders_to_be_sent
    end
  end

  before_create :set_free_plans
  def set_free_plans(design_id=nil)
    if self.event_type == EVENT_TYPES[:MOVIE]
      #event type should remain MOVIE if I only change the design
    elsif design_id
      self.event_type = Design.find(design_id).is_premium? ? EVENT_TYPES[:PREMIUM] : EVENT_TYPES[:STANDARD]
    else
      self.event_type = self.design.is_premium? ? EVENT_TYPES[:PREMIUM] : EVENT_TYPES[:STANDARD]
    end
    plan, price = Eventify.emails_plan(self.event_type, 1)
    self.emails_plan = plan if price.zero?
  end

  def stage2_preview_dimensions(current_locale, ratio)
    res = {
      'text-align' => msg_text_align.blank? ? nil : msg_text_align == "center" ? msg_text_align : current_locale == "he" ? "right" : "left",
      :color => msg_color.blank? ? nil : msg_color,
      "font-size" => msg_font_size.blank? ? nil : "#{msg_font_size.to_int}px",
      "font-family" => "#{font_body}"
    }
    r = ratio || RATIO
    unless text_width.blank?
      res.merge!({
        :width =>  "#{(text_width/r).to_int}px",
        :height => "#{(text_height/r).to_int}px"
      })
    end
    unless text_top_y.blank?
      res.merge!({
        :top =>    "#{(text_top_y/r).to_int}px",
        :left =>   "#{(text_top_x/r).to_int}px",
      })
    end
    @stage2_preview_dimensions ||= res.delete_if{|key,value| value.blank?}
  end

  def stage2_title_dimensions(current_locale, ratio)
    res = {
      'text-align' => title_text_align.blank? ? nil : title_text_align == "center" ? title_text_align : current_locale == "he" ? "right" : "left",
      :color => title_color.blank? ? nil : title_color,
      "font-size" => title_font_size.blank? ? nil : "#{title_font_size.to_int}px",
      "font-family" => "#{font_title}"
    }
    r = ratio || RATIO
    unless title_width.blank?
      res.merge!({
        :width =>  "#{(title_width/r).to_int}px",
        :height => "#{(title_height/r).to_int}px"
      })
    end
    unless title_top_y.blank?
      res.merge!({
        :top =>    "#{(title_top_y/r).to_int}px",
        :left =>   "#{(title_top_x/r).to_int}px",
      })
    end
    @stage2_title_dimensions ||= res.delete_if{|key,value| value.blank?}
  end

protected

  def _cancel_pending_invitations!
    guests.scheduled_to_invite_by_sms.update_all("send_sms_invitation_at = NULL")
    # emails should already be sent
  end

  def _disable_reminders!
    reminders.update_all("is_active = '0'")
  end

  def _cancel_sms_reminders!
    reminders.update_all("by_sms = '0'")
    reminders.update_all("is_active = '0'", "by_sms = '0' AND by_email = '0'")
  end

  def _cancel_sms_invitations!
    guests.update_all("send_sms = '0'")
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
