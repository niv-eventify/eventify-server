class Guest < ActiveRecord::Base
  belongs_to :event
  validates_presence_of :name

  validates_format_of   :email, :with => String::EMAIL_REGEX, :message => N_("does't look like an email"), :allow_blank => true, :allow_nil => true
  validates_presence_of :email, :if => proc {|guest| guest.send_email?}
  validates_uniqueness_of :email, :scope => :event_id, :allow_nil => true, :allow_blank => true

  validates_format_of   :mobile_phone, :with => String::PHONE_REGEX, :message => N_("does't look like a mobile phone number"), :allow_blank => true, :allow_nil => true
  validates_presence_of :mobile_phone, :if => proc {|guest| guest.send_sms?}
  validates_uniqueness_of :mobile_phone, :scope => :event_id, :allow_nil => true, :allow_blank => true

  attr_accessible :name, :email, :mobile_phone, :send_email, :send_sms, :allow_snow_ball, :attendees_count

  after_create :increase_stage_passed

  RSVPS = {
    :yes => 1,
    :no => 0,
    :may_be => 2
  }

  def increase_stage_passed
    if 2 == event.stage_passed.to_i
      event.stage_passed = 3
      event.save
    end
  end

  def send_email_invitation!
    self.email_token ||= Astrails.generate_token
    self.email_invitation_sent_at = Time.now.utc
    event.update_last_invitation_sent!(email_invitation_sent_at)
    save!
    # TODO - send email
  end

  def before_destroy
    return false if invited?
  end

  def invited?
    email_invitation_sent_at || sms_invitation_sent_at
  end

  def should_send_invitation?
    !rsvp.nil?
  end
end


__END__

editable names/emails - ?