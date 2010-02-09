class Guest < ActiveRecord::Base
  belongs_to :event
  validates_presence_of :name
  validates_format_of   :email, :with => String::EMAIL_REGEX, :message => N_("does't look like an email"), :allow_blank => true, :allow_nil => true
  attr_accessible :name, :email, :mobile_phone, :send_email, :send_sms, :allow_snow_ball
  validates_uniqueness_of :email, :scope => :event_id, :allow_nil => true, :allow_blank => true

  after_create :increase_stage_passed

  def validate
    errors.add(:email, _("provide email or mobile phone")) if email.blank? && mobile_phone.blank?
  end

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
    if invited?
      false
    end
  end

  def invited?
    email_invitation_sent_at || sms_invitation_sent_at
  end
end


__END__

editable names/emails - ?
verify sms/email invitations if phone/email is present