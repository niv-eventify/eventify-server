module Astrails
  def self.generate_token
    SecureRandom.base64(16).tr('+/=', '-_ ').strip.delete("\n")
  end

  SEND_SMS_AFTER_HOUR  = 10
  SEND_SMS_BEFORE_HOUR = 21

  def self.too_late_to_send_sms?(hour)
    hour > SEND_SMS_BEFORE_HOUR
  end

  def self.too_early_to_send_sms?(hour)
    hour < SEND_SMS_AFTER_HOUR
  end

  def self.good_time_to_send_sms?(tz)
    (Astrails::SEND_SMS_AFTER_HOUR..Astrails::SEND_SMS_BEFORE_HOUR).include?(Time.now.utc.in_time_zone(tz).hour)
  end
end