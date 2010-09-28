module Eventify

  # all prices are in ogorot

  if ::IS_STAGE
    EMAILS_PLAN_PROPERTIES = [
      [0..1, [1, 0]],
      [2..2, [2, 100]],
      [3..300, [300, 25000]],
      [301..400, [400, 35000]],
      [401..500, [500, 45000]]
    ]
    SMS_BATCH = 5
  else
    EMAILS_PLAN_PROPERTIES = [
      [0..100, [100, 0]],
      [101..200, [200, 15000]],
      [201..300, [300, 25000]],
      [301..400, [400, 35000]],
      [401..500, [500, 45000]]
    ]
    SMS_BATCH = 25
  end


    SMS_PRICE = 20 # 0.2nis

    PRINTS_BATCH = 50
    PRINTS_PRICE = 375 # 3.75nis

  class << self
    def emails_plan(count, override_max_price = nil)
      EMAILS_PLAN_PROPERTIES.each do |p|
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