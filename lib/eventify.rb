module Eventify

  # all prices are in ogorot

  if DUMMY_PAYMENT_PROGRAM
    EMAILS_PLAN_PROPERTIES = [
      [0..1, [1, 0]],
      [2..2, [2, 500]],
      [3..300, [300, 2000]],
      [301..400, [400, 3000]],
      [401..500, [500, 4000]],
      [501..600, [600, 5000]]
    ]
    PREMIUM_EMAILS_PLAN_PROPERTIES = [
      [0..1, [1, 0]],
      [2..2, [2, 2000]],
      [3..300, [300, 3000]],
      [301..400, [400, 5000]],
      [401..500, [500, 9000]]
    ]
    SMS_BATCH = 1
  else
    EMAILS_PLAN_PROPERTIES = [
      [0..1, [1, 0]],
      [2..2, [2, 500]],
      [3..300, [300, 2000]],
      [301..400, [400, 3000]],
      [401..500, [500, 4000]],
      [501..600, [600, 5000]]
    ]
    PREMIUM_EMAILS_PLAN_PROPERTIES = [
      [0..2, [2, 0]],
      [3..20, [20, 3000]],
      [21..50, [50, 6000]],
      [51..200, [200, 5000]],
      [201..500, [500, 40000]]
    ]

    SMS_BATCH = 20
  end

  SMS_PRICE = 35 # 0.35nis

  PRINTS_BATCH = 50
  PRINTS_PRICE = 375 # 3.75nis

  #TODO: In case we wish to change this after some designers exist - we'll need to add this data on a per designer level with the current values inserted for all existing designers
  DESIGNER_PERCENTAGE = 0.25
  DESIGNER_MINIMAL_PAYMENT = 100

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
