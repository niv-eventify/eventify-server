module Astrails
  def self.generate_token
    SecureRandom.base64(16).tr('+/=', '-_ ').strip.delete("\n")
  end

  SEND_SMS_AFTER_HOUR  = 10
  SEND_SMS_BEFORE_HOUR = 21

  def self.best_time_to_send_sms(starting_from, time_zone)
    hour = starting_from.in_time_zone(time_zone).hour

    if Astrails.too_late_to_send_sms?(hour)
      (((starting_from + 1.day).in_time_zone(time_zone).beginning_of_day) + 10.hours).utc
    elsif Astrails.too_early_to_send_sms?(hour)
      ((starting_from.in_time_zone(time_zone).beginning_of_day) + 10.hours).utc
    else
      starting_from
    end
  end

  def self.too_late_to_send_sms?(hour)
    hour > SEND_SMS_BEFORE_HOUR
  end

  def self.too_early_to_send_sms?(hour)
    hour < SEND_SMS_AFTER_HOUR
  end

  def self.good_time_to_send_sms?(starting_from, time_zone)
    (Astrails::SEND_SMS_AFTER_HOUR..Astrails::SEND_SMS_BEFORE_HOUR).include?(starting_from.in_time_zone(time_zone).hour)
  end
end