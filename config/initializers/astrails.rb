module Astrails
  def self.generate_token
    SecureRandom.base64(16).tr('+/=', '-_ ').strip.delete("\n")
  end

  def self.good_time_to_send_sms?(tz)
    h = Time.now.utc.in_time_zone(tz).hour
    h > 10 && h < 21
  end
end