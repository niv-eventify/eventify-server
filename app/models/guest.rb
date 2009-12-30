class Guest < ActiveRecord::Base
  belongs_to :event
  validates_presence_of :name
  validates_format_of   :email, :with => String::EMAIL_REGEX, :message => N_("does't look like an email"), :allow_blank => true, :allow_nil => true
  attr_accessible :name, :email, :mobile_phone, :send_email, :send_sms, :allow_snow_ball

  def validate
    errors.add(:email, _("provide email or mobile phone")) if email.blank? && mobile_phone.blank?
  end
end
