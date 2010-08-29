class Payment < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  attr_accessible :emails_plan, :sms_plan, :prints_plan, :amount

  validates_presence_of :emails_plan, :sms_plan, :prints_plan, :amount

  def validate

  end

  def calc_defaults
    self.sms_plan, extra_payment_sms = calc_sms_plan
    self.prints_plan, extra_payment_prints = calc_prints_plan
    self.emails_plan, extra_payment_emails = calc_emails_plan

    self.amount = extra_payment_sms + extra_payment_prints + extra_payment_emails
  end

protected
  def calc_sms_plan
    new_plan, full_payment = Eventify.sms_plan(event.total_sms_count)
    _, already_paid        = Eventify.sms_plan(event.sms_plan)

    [new_plan, full_payment - already_paid]
  end


  def calc_prints_plan
    new_plan, full_payment = Eventify.prints_plan(event.prints_ordered)
    _, already_paid        = Eventify.prints_plan(event.prints_plan)

    [new_plan, full_payment - already_paid]
  end

  def calc_emails_plan
    new_plan, full_payment = Eventify.emails_plan(event.guests.count)
    _, already_paid        = Eventify.emails_plan(event.emails_plan)

    [new_plan, full_payment - already_paid]
  end
end
