class PaymentError < RuntimeError; end

class Payment < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  belongs_to :succeed_netpay_log, :class_name => "NetpayLog"
  has_many   :payment_attempts, :class_name => "NetpayLog", :foreign_key => :context

  attr_accessor :cc, :expiration_month, :expiration_year, :name_on_card,
    :ccv2, :email, :user_ident, :phone_number, :transaction_description

  attr_reader :extra_payment_sms, :extra_payment_prints

  attr_accessible :emails_plan, :sms_plan, :prints_plan, :amount

  PAYMENT_DETAILS_FIELDS = [:cc, :expiration_month, :expiration_year, :name_on_card,
    :ccv2, :email, :user_ident, :phone_number]
  attr_reader :payment_status_description

  validates_presence_of :emails_plan, :sms_plan, :prints_plan, :amount,
    :cc, :expiration_month, :expiration_year, :name_on_card,
    :ccv2, :email, :user_ident, :phone_number, 
    :on => :update

  named_scope :paid, :conditions => "paid_at IS NOT NULL"
  named_scope :for_list, :order => "paid_at DESC", :include => :event 

  before_validation_on_create :set_plans

  def pay!
    raise ActiveRecord::RecordInvalid.new(self) unless valid?

    transaction_description = _("Eventify - payment for %{event_name}") % {:event_name => event.name}

    s = Netpay::SilentPost.new(NETPAY_MERCHANT_ID, self.id.to_s, NETPAY_SKIP_SSL)
    s.process(cc, expiration_month, expiration_year, name_on_card, amount, ccv2, email, user_ident, phone_number, transaction_description, "ILS")

    @payment_status_description = s.parsed_response[:ReplyDesc]
    raise PaymentError unless s.success?

    self.paid_at = Time.now.utc
    self.succeed_netpay_log_id = s.log_id
    save!
    # update event plans
    self.event.emails_plan = emails_plan
    self.event.sms_plan = sms_plan
    self.event.prints_plan = prints_plan
    self.event.save!
    true
  end

  def set_plans
    self.emails_plan_prev = event.emails_plan
    self.sms_plan_prev = event.sms_plan
    self.prints_plan_prev = event.prints_plan

    _, self.pay_sms        = Payment.upgrade_plan(:sms_plan, sms_plan, event.sms_plan)
    _, self.pay_prints     = Payment.upgrade_plan(:prints_plan, prints_plan, event.prints_plan)
    _, self.pay_emails     = Payment.upgrade_plan(:emails_plan, emails_plan, event.emails_plan)
  end

  def load_payment_details(opts)
    PAYMENT_DETAILS_FIELDS.each do |f|
      self.send("#{f}=", opts[f])
    end
  end

  def validate
    errors.add(:base, "manual hack?") if self.amount != calculated_amount || payment_is_not_enough?
  end

  def set_names_from_user
    self.email = user.email
    self.name_on_card = user.name
  end

  def payment_is_not_enough?
    p = event.payments.new
    p.calc_defaults

    (emails_plan < p.emails_plan) || (sms_plan < p.sms_plan) || (prints_plan < p.prints_plan)
  end

  def calc_defaults
    self.sms_plan, @extra_payment_sms       = Payment.upgrade_plan(:sms_plan, event.total_sms_count, event.sms_plan)
    self.prints_plan, @extra_payment_prints = Payment.upgrade_plan(:prints_plan, event.prints_ordered, event.prints_plan)
    self.emails_plan, extra_payment_emails  = Payment.upgrade_plan(:emails_plan, event.total_invitations_count, event.emails_plan)

    self.amount = @extra_payment_sms + @extra_payment_prints + extra_payment_emails
    self
  end

  def calculated_amount
    set_plans unless pay_sms || pay_prints || pay_emails
    pay_sms + pay_prints + pay_emails
  end

  def upgrade?
    @upgrade ||= (event.payments.paid.count > 0)
  end

  def email_upgrade_price(to_count)
    _, price = Payment.upgrade_plan(:emails_plan, to_count, event.emails_plan)
    price < 0 ? 0 : price
  end

  def self.upgrade_plan(plan, new_count, old_count)
    new_plan, full_payment = Eventify.send(plan, new_count)
    _, already_paid        = Eventify.send(plan, old_count)

    [new_plan, full_payment - already_paid]
  end
end
