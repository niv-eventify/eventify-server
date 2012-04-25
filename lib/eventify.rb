module Eventify

  # all prices are in ogorot

  if DUMMY_PAYMENT_PROGRAM
    EMAILS_PLAN_PROPERTIES = [
      [0..1, [1, 0]],
      [2..2, [2, 0]],
      [3..300, [300, 0]],
      [301..400, [400, 0]],
      [401..500, [500, 0]]
    ]
    PREMIUM_EMAILS_PLAN_PROPERTIES = [
      [0..1, [1, 0]],
      [2..2, [2, 2000]],
      [3..300, [300, 3000]],
      [301..400, [400, 5000]],
      [401..500, [500, 9000]]
    ]
    SMS_BATCH = 5
  else
    EMAILS_PLAN_PROPERTIES = [
      [0..2, [2, 0]],
      [3..20, [20, 0]],
      [21..50, [50, 0]],
      [51..100, [100, 0]],
      [101..500, [500, 0]]
    ]
    PREMIUM_EMAILS_PLAN_PROPERTIES = [
      [0..2, [2, 0]],
      [3..20, [20, 2000]],
      [21..50, [50, 3000]],
      [51..100, [100, 5000]],
      [101..500, [500, 9000]]
    ]

    SMS_BATCH = 20
  end

  SMS_PRICE = 35 # 0.35nis

  PRINTS_BATCH = 50
  PRINTS_PRICE = 375 # 3.75nis

  class << self
    def emails_plan(count, override_max_price = nil)
      EMAILS_PLAN_PROPERTIES.each do |p|
        return p.last if p.first.include?(count)
      end

      [count, count * (override_max_price || 100)]
    end

    def premium_emails_plan(count, override_max_price = nil)
      PREMIUM_EMAILS_PLAN_PROPERTIES.each do |p|
        return p.last if p.first.include?(count)
      end

      [count, count * (override_max_price || 100)]
    end

    def flat_plan(count, batch_size, unit_price)
      batches = (count / batch_size).to_i
      batches += 1 if (count % batch_size) > 0
      [batches * batch_size, batches * batch_size * unit_price]
    end

    def sms_plan(count)
      flat_plan(count, SMS_BATCH, SMS_PRICE)
    end

    def prints_plan(count)
      flat_plan(count, PRINTS_BATCH, PRINTS_PRICE)
    end

  end
end