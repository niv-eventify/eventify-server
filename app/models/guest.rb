class Guest < ActiveRecord::Base
  belongs_to :event
  validates_presence_of :name

  define_index do
    indexes name, email
    has :event_id
  end

  MASS_UPDATABLE = ["send_sms", "send_email"]

  validates_format_of   :email, :with => String::EMAIL_REGEX, :message => N_("does't look like an email"), :allow_blank => true, :allow_nil => true
  validates_presence_of :email, :if => proc {|guest| guest.send_email?}
  validates_uniqueness_of :email, :scope => :event_id, :allow_nil => true, :allow_blank => true

  validates_phone_number :mobile_phone

  validates_presence_of :mobile_phone, :if => proc {|guest| guest.send_sms?}
  validates_uniqueness_of :mobile_phone, :scope => :event_id, :allow_nil => true, :allow_blank => true

  attr_accessor :force_resend_email, :force_resend_sms

  attr_accessible :name, :email, :mobile_phone, :send_email, :send_sms, :allow_snow_ball, :attendees_count, :rsvp, :first_viewed_invitation_at, :takings_attributes, :force_resend_email, :force_resend_sms

  named_scope :invite_by_sms, {:conditions => {:send_sms => true}}
  named_scope :invite_by_email, {:conditions => {:send_email => true}}

  named_scope :invited_or_scheduled, {:conditions => "((guests.sms_invitation_sent_at IS NOT NULL OR guests.send_sms_invitation_at IS NOT NULL) AND guests.send_sms = 1) OR (guests.email_invitation_sent_at IS NOT NULL AND guests.send_email = '1')"}

  named_scope :invited_by_email, {:conditions => "guests.email_invitation_sent_at IS NOT NULL AND guests.send_email = '1'"}
  named_scope :invited_by_sms, {:conditions => "guests.sms_invitation_sent_at IS NOT NULL AND guests.send_sms = 1"}

  named_scope :any_invitation_sent, {:conditions => "guests.any_invitation_sent = 1"}
  named_scope :no_invitation_sent, {:conditions => "guests.any_invitation_sent = 0"}

  named_scope :not_invited_by_sms, {:conditions => "guests.send_sms_invitation_at IS NULL AND guests.sms_invitation_sent_at IS NULL AND guests.send_sms = 1"}
  named_scope :sms_invitation_failed, {:conditions => "guests.sms_invitation_failed_at IS NOT NULL"}

  named_scope :scheduled_to_invite_by_sms, {:conditions => "guests.send_sms_invitation_at IS NOT NULL AND guests.send_sms = 1"}
  named_scope :scheduled_to_invite_by_sms_overdue, lambda {{:conditions => ["guests.send_sms_invitation_at < ? AND guests.send_sms_invitation_at IS NOT NULL AND guests.send_sms = 1", Time.now.utc]}}

  named_scope :not_invited_by_email, {:conditions => "guests.send_email_invitation_at IS NULL AND guests.email_invitation_sent_at IS NULL AND guests.send_email = '1'"}

  named_scope :with_ids, lambda {|ids| {:conditions => ["guests.id in (?)", ids]}}
  named_scope :summary_email_not_sent, :conditions => "guests.summary_email_sent_at IS NULL"

  named_scope :by_rsvp, :order => "rsvp,name"
  named_scope :by_name, :order => "name"
  named_scope :rsvp_no,             :conditions => {:rsvp => 0}
  named_scope :rsvp_yes,            :conditions => {:rsvp => 1}
  named_scope :rsvp_maybe,          :conditions => {:rsvp => 2}
  #not_responded = not_rsvped + not_opened_invite
  named_scope :rsvp_not_responded,  {:conditions => "guests.rsvp IS NULL AND guests.email_invitation_sent_at IS NOT NULL AND guests.send_email = '1'"}
  named_scope :rsvp_not_rsvped, {:conditions => "guests.first_viewed_invitation_at IS NOT NULL AND guests.rsvp IS NULL"}
  named_scope :rsvp_not_opened_invite, {:conditions => "guests.first_viewed_invitation_at IS NULL AND guests.email_invitation_sent_at IS NOT NULL AND guests.send_email = '1' AND guests.rsvp IS NULL"}
  named_scope :not_bounced_by_email, lambda { |email|
    {
      :include => :event,
      :conditions => ["guests.bounced_at IS NULL AND guests.email = ? AND events.starting_at >= ?", email, Time.now.utc]
    }
  }
  named_scope :bounced, {:conditions => "guests.bounced_at IS NOT NULL"}

  after_create :reset_event_stage_passed
  after_update :check_invitation_failures # TODO -smth is wrong here
  before_update :update_summary_status
  before_update :update_invitation_methods
  before_update :update_invitation_state
  after_update :delayed_send_summary_status
  after_update :check_takings_status
  before_update :check_unbounce
  after_create :save_to_contacts

  attr_accessor :save_as_contact
  attr_accessible :save_as_contact
  has_many :sms_messages

  has_many :takings
  has_many :things_to_bring, :through => :takings

  def possible_takings
    @possible_takings ||= returning(takings.all(:include => :thing)) do |res|
      taking_thing_ids = res.collect(&:thing_id)
      event.things.left.each do |other_thing|
        next if taking_thing_ids.member?(other_thing.id)
        res << other_thing.to_taking
      end
    end
  end

  def takings_attributes=(new_takings)
    @things_amounts_adjusted = false

    new_takings.values.each do |t|
      taking = if t[:id]
        change_existing_taking(t)
      elsif !t[:amount].to_i.zero?
        takings.create(t)
      end
      @things_amounts_adjusted = @things_amounts_adjusted || taking.overtaken? if taking
    end
  end

  def things_amounts_adjusted?
    @things_amounts_adjusted
  end

  def change_existing_taking(t)
    taking = takings.find(t[:id])
    if !t[:amount].to_i.zero?
      taking.amount = t[:amount]
      taking.save
      taking.destroy if taking.amount.zero?
    else
      taking.destroy
    end

    taking
  end

  RSVP_TEXT = [N_("No"), N_("Yes"), N_("May Be")]

  def can_change_number_of_guests?
    1 == rsvp # yes
  end

  def can_choose_things_to_bring?
    1 == rsvp # yes
  end

  def rsvp_text
    return _("not yet responded") unless rsvp
    s_(RSVP_TEXT[rsvp])
  end

  def reset_event_stage_passed
    event.stage_passed = 3
    event.save(false)
  end

  def update_invitation_methods
    self.send_email = true if force_resend_email || (!email.blank? && email_changed? && 1 == changes.keys.size)
    self.email_invitation_sent_at = self.send_email_invitation_at = nil if email_changed? || force_resend_email
    self.send_sms = true if force_resend_sms
    self.sms_invitation_sent_at   = self.send_sms_invitation_at = nil if mobile_phone_changed? || force_resend_sms
    # when email or phone is changed, or we wants to re-send invitation - it's like a new guest, so we reset any_invitation_sent
    self.any_invitation_sent = false if email_changed? || mobile_phone_changed? || force_resend_sms || force_resend_email
    true
  end

  def need_to_resend_invitation?
    return true if force_resend_sms || force_resend_email
    return true if changed_to_nil?(:email_invitation_sent_at) || changed_to_nil?(:sms_invitation_sent_at)
    return true if send_email? && (email_changed? || send_email_changed?)
    return true if send_sms? && (mobile_phone_changed? || send_sms_changed?)
    false
  end

  def invitation_sent_or_scheduled?(delivery_method)
    send("#{delivery_method}_invitation_sent_at") || send("send_#{delivery_method}_invitation_at")
  end

  def update_invitation_state
    return unless need_to_resend_invitation?
    # need to send invitations
    event.stage_passed = 3
    event.save if event.stage_passed_changed?
  end

  def update_summary_status
    if rsvp_changed?
      self.summary_email_sent_at = event.immediately_send_rsvp? ? Time.now.utc : nil
    end
  end

  def delayed_send_summary_status
    send_later(:send_summary_status) if rsvp_changed? && event.immediately_send_rsvp?
  end

  def send_summary_status
    rsvps = {rsvp => [to_rsvp_email_params]}
    start_datetime = event.with_time_zone do
      event.starting_at
    end
    start_time = start_datetime.to_s(:isra_time)
    start_date = start_datetime.to_s(:isra_date)
    I18n.with_locale(event.language) {Notifier.deliver_guests_summary(event, rsvps, nil, start_time, start_date)}
  end

  def to_rsvp_email_params
    {:name => name, :attendees_count => attendees_count}
  end

  def reset_summary_status!
    self.summary_email_sent_at = Time.now.utc
    save!
  end

  def self.delayed_sms_cron_job
    loop do
      guests = scheduled_to_invite_by_sms_overdue.all(:limit => 10)
      break if guests.blank?

      mass_prepare_sms(guests)
    end
  end

  def self.filter_rsvps(filter, current_event)
    guests = []
    filter_arr = filter.split(",")
    if filter_arr.length == 0
      guests = current_event.guests
    else
      if filter_arr.include?("no")
        guests.concat(current_event.guests.rsvp_no)
      end
      if filter_arr.include?("yes")
        guests.concat(current_event.guests.rsvp_yes)
      end
      if filter_arr.include?("maybe")
        guests.concat(current_event.guests.rsvp_maybe)
      end
      if filter_arr.include?("not_responded")
        guests.concat(current_event.guests.rsvp_not_responded)
      end
    end
    return guests
  end

  def self.mass_prepare_sms(guests)
    guests.collect(&:prepare_sms_invitation!)
  end

  def prepare_sms_invitation!
    resend = self.delayed_sms_resend

    self.sms_invitation_sent_at, self.send_sms_invitation_at = send_sms_invitation_at, nil
    self.any_invitation_sent = true
    self.delayed_sms_resend = nil
    save!

    send_later(:send_sms_invitation!, resend)
  end

  def send_sms_invitation!(resend = false)
    sms =  event.with_time_zone do
      msg = resend ? event.sms_resend_message : event.sms_message
      logger.info("guest_id: #{id}, msg: #{msg}")
      sms_messages.create!(:kind => "invitation", :message => msg)
    end

    sms.send_sms!

    unless sms.success?
      self.sms_invitation_failed_at = Time.now.utc
      save!
    end
  end

  def prepare_email_invitation!(resend)
    self.email_token ||= Astrails.generate_token
    self.email_invitation_sent_at, self.send_email_invitation_at = send_email_invitation_at, nil
    self.any_invitation_sent = true
    save!

    send_later(:send_email_invitation!, resend)
  end

  def send_email_invitation!(resend = false)
    I18n.with_locale(event.language) do
      event.with_time_zone do
        if resend
          Notifier.deliver_invite_resend_guest(self)
        else
          Notifier.deliver_invite_guest(self)
        end
      end
    end
  end

  def send_reminder!(reminder)
    logger.info "#{Time.now.utc.to_s(:db)} sending reminder_id=#{reminder.id} to guest_id=#{self.id}\n"

    unless invited?
      logger.info "#{Time.now.utc.to_s(:db)} sending reminder_id=#{reminder.id} to guest_id=#{self.id} - skipped, guest is not invited\n"
      return
    end

    I18n.with_locale(event.language) do
      event.with_time_zone do
        if reminder.by_email? && self.send_email?
          # TODO: handle delivery errors

          Notifier.deliver_guest_reminder(self, reminder.email_subject, reminder.email_body)
          reminder.reminder_logs.create(:guest_id => self.id, :destination => email, :message => "#{reminder.email_subject}/#{reminder.email_body}", :status => "success", :kind => "email")
        end

        if reminder.by_sms? && self.send_sms?
          sms = sms_messages.create!(:kind => "reminder", :message => reminder.sms_message)

          sms.send_sms!
          reminder.reminder_logs.create(:guest_id => self.id, :destination => mobile_phone, :message => reminder.sms_message, :status => (sms.success? ? "success" : "failure"), :kind => "sms")
        end
      end
    end

    logger.info "#{Time.now.utc.to_s(:db)} sending reminder_id=#{reminder.id} to guest_id=#{self.id} - reminder sent\n"
  end

  def before_destroy
    return false unless allow_delete?
  end

  def invited?
    invitation_sent_or_scheduled?(:email) || invitation_sent_or_scheduled?(:sms)
  end

  def scheduled_to_invite_by_email?
    send_email_invitation_at && send_email?
  end

  def scheduled_to_invite_by_sms?
    send_sms_invitation_at && send_sms?
  end

  def email_recipient
    "#{name} <#{email}>"
  end

  def check_invitation_failures
    # reset sms errors when mobile phone changed
    if send_sms? && !sms_invitation_failed_at.nil? && mobile_phone_changed?
      self.send_sms_invitation_at = self.sms_invitation_sent_at = self.sms_invitation_failed_at = nil
    end
  end

  def check_takings_status
    if rsvp_changed? && 1 != rsvp # not YES
      self.takings.each do |taking|
        taking.skip_noitfication = true
        taking.destroy
      end
    end
  end

  def self.total_attendees_count
    calculate(:sum, "case when attendees_count IS NULL then 1 else attendees_count end")
  end

  def allow_delete?
    # any email message ever intended to be sent
    return false if !email_token.blank?
    # any sms message ever sent
    return false if !sms_messages.count.zero?
    # just invited (or scheduled to invite)
    return false if invited?
    true
  end

  def bounce!(status, reason)
    self.bounced_at = Time.now.utc
    self.bounce_status = status
    self.bounce_reason = reason
    save!
  end

  def check_unbounce
    unbounce if email_changed?
  end

  def unbounce
    self.bounce_reason = self.bounce_status = self.bounced_at = nil
  end

  def bounced?
    bounced_at
  end

  def send_cancellation_email(subject, content)
    I18n.with_locale(event.language) do
      event.with_time_zone do
        Notifier.deliver_event_cancelled(self, subject, content)
      end
    end
  end

  def send_cancellation_sms(message)
    I18n.with_locale(event.language) do
      event.with_time_zone do
        sms = sms_messages.create!(:kind => "cancel", :message => message)
        sms.send_sms!
      end
    end
  end

  attr_reader :suggested_name
  def save_to_contacts
    return unless save_as_contact
    suggested_name = event.user.contacts.find_by_email(email).try(:name) if event.user.contacts.add(name, email).new_record?
    @suggested_name = suggested_name if suggested_name && suggested_name != name
  end
end
