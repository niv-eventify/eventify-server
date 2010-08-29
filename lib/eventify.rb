module Eventify
  class << self

    # all prices are in ogorot

    def emails_plan(count, override_max_price = nil)
      case count
      when 0..50
        [50, 0]
      when 51..100
        [100, 5000]
      when 101..200
        [200, 15000]
      when 201..300
        [300, 25000]
      when 301..400
        [400, 35000]
      when 401..500
        [500, 45000]
      else
        [count, count * (override_max_price || 100)]
      end
    end

    def flat_plan(count, batch_size, unit_price)
      batches = (count / batch_size).to_i
      batches += 1 if (count % batch_size) > 0
      [batches * batch_size, batches * batch_size * unit_price]
    end

    SMS_BATCH = 25
    SMS_PRICE = 20 # 0.2nis
    def sms_plan(count)
      flat_plan(count, SMS_BATCH, SMS_PRICE)
    end

    PRINTS_BATCH = 50
    PRINTS_PRICE = 375 # 3.75nis
    def prints_plan(count)
      flat_plan(count, PRINTS_BATCH, PRINTS_PRICE)
    end

  end
end