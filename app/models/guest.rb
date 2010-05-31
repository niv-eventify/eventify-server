class Guest < ActiveRecord::Base
  belongs_to :event
  validates_presence_of :name

  define_index do
    indexes name, email
    has :event_id
  end

  validates_format_of   :email, :with => String::EMAIL_REGEX, :message => N_("does't look like an email"), :allow_blank => true, :allow_nil => true
  validates_presence_of :email, :if => proc {|guest| guest.send_email?}
  validates_uniqueness_of :email, :scope => :event_id, :allow_nil => true, :allow_blank => true

  validates_format_of   :mobile_phone, :with => String::PHONE_REGEX, :message => N_("does't look like a mobile phone number, allowed: +972501234567 or 0501234567"), :allow_blank => true, :allow_nil => true
  validates_presence_of :mobile_phone, :if => proc {|guest| guest.send_sms?}
  validates_uniqueness_of :mobile_phone, :scope => :event_id, :allow_nil => true, :allow_blank => true

  attr_accessible :name, :email, :mobile_phone, :send_email, :send_sms, :allow_snow_ball, :attendees_count, :rsvp, :takings_attributes

  named_scope :invite_by_sms, {:conditions => {:send_sms => true}}
  named_scope :invite_by_email, {:conditions => {:send_email => true}}

  named_scope :not_invited_by_sms, {:conditions => "guests.send_sms_invitation_at IS NULL AND guests.sms_invitation_sent_at IS NULL AND guests.send_sms = 1"}
  named_scope :scheduled_to_invite_by_sms, {:conditions => "guests.send_sms_invitation_at IS NOT NULL AND guests.send_sms = 1"}
  named_scope :sms_invitation_failed, {:conditions => "guests.sms_invitation_failed_at IS NOT NULL"}

  named_scope :not_invited_by_email, {:conditions => "guests.send_email_invitation_at IS NULL AND guests.email_invitation_sent_at IS NULL AND guests.send_email = 1"}
  named_scope :scheduled_to_invite_by_email, {:conditions => "guests.send_email_invitation_at IS NOT NULL AND guests.send_email = 1"}

  named_scope :with_ids, lambda {|ids| {:conditions => ["guests.id in (?)", ids]}}
  named_scope :summary_email_not_sent, :conditions => "guests.summary_email_sent_at IS NULL"

  named_scope :rsvp_no,             :conditions => {:rsvp => 0}
  named_scope :rsvp_yes,            :conditions => {:rsvp => 1}
  named_scope :rsvp_maybe,          :conditions => {:rsvp => 2}
  named_scope :rsvp_not_responded,  :conditions => {:rsvp => nil}

  after_create :reset_event_stage_passed
  after_update :check_invitation_failures # TODO -smth is wrong here
  before_update :update_summary_status
  before_update :update_invitation_methods
  before_update :update_invitation_state
  after_update :send_summary_status
  after_update :check_takings_status

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
    self.send_email = true if !email.blank? && email_changed? && 1 == changes.keys.size

    self.email_invitation_sent_at = self.send_email_invitation_at = nil if email_changed?
    self.sms_invitation_sent_at   = self.send_sms_invitation_at = nil if mobile_phone_changed?
  end

  def need_to_resend_invitation?
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

  def send_summary_status
    if rsvp_changed? && event.immediately_send_rsvp?
      rsvps = {rsvp => [to_rsvp_email_params]}
      I18n.with_locale(event.language) {Notifier.send_later(:deliver_guests_summary, event, rsvps, nil)}
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
    self.sms_invitation_sent_at, self.send_sms_invitation_at = timestamp, nil
    save!
    send_later(:send_sms_invitation!)
  end

  def send_sms_invitation!
    sms = sms_messages.create!(:kind => "invitation", :message => event.sms_message)

    sms.send_sms!

    unless sms.success?
      self.sms_invitation_failed_at = Time.now.utc
      save!
    end
  end

  def prepare_email_invitation!(timestamp)
    self.email_token ||= Astrails.generate_token
    self.email_invitation_sent_at, self.send_email_invitation_at = timestamp, nil
    save!
    send_later(:send_email_invitation!)
  end

  def send_email_invitation!
    I18n.with_locale(event.language) { Notifier.deliver_invite_guest(self) }
  end

  def send_reminder!(reminder)
    logger.info "#{Time.now.utc.to_s(:db)} sending reminder_id=#{reminder.id} to guest_id=#{self.id}\n"

    unless invited?
      logger.info "#{Time.now.utc.to_s(:db)} sending reminder_id=#{reminder.id} to guest_id=#{self.id} - skipped, guest is not invited\n"
      return
    end

    if reminder.by_email?
      # TODO: handle delivery errors
      Notifier.deliver_guest_reminder(self, reminder.email_subject, reminder.email_body)
      reminder.reminder_logs.create(:guest_id => self.id, :destination => email, :message => "#{reminder.email_subject}/#{reminder.email_body}", :status => "success", :kind => "email")
    end

    if reminder.by_sms?
      sms = sms_messages.create!(:kind => "reminder", :message => reminder.sms_message)

      sms.send_sms!
      reminder.reminder_logs.create(:guest_id => self.id, :destination => mobile_phone, :message => reminder.sms_message, :status => (sms.success? ? "success" : "failure"), :kind => "sms")
    end

    logger.info "#{Time.now.utc.to_s(:db)} sending reminder_id=#{reminder.id} to guest_id=#{self.id} - reminder sent\n"
  end

  def before_destroy
    return false if invited?
  end

  def invited?
    invitation_sent_or_scheduled?(:email) || invitation_sent_or_scheduled?(:sms)
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
    calculate(:sum, "if(attendees_count IS NULL, 1, attendees_count)")
  end
end
