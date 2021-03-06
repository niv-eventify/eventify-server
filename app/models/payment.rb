class PaymentError < RuntimeError; end

class Payment < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  has_many   :payment_attempts, :class_name => "NetpayLog", :foreign_key => :context

  attr_accessor :email, :name_on_card

  attr_reader :extra_payment_sms, :extra_payment_prints

  attr_accessible :emails_plan, :sms_plan, :prints_plan, :amount, :transaction_id, :is_agreed_to_terms

  PAYMENT_DETAILS_FIELDS = [:cc, :expiration_month, :expiration_year, :name_on_card,
    :ccv2, :email, :user_ident, :phone_number]
  attr_reader :payment_status_description

  validates_presence_of :emails_plan, :sms_plan,
    # :prints_plan,
    :amount, :transaction_id, :on => :update

  named_scope :paid, :conditions => "paid_at IS NOT NULL"
  named_scope :for_list, :order => "paid_at DESC", :include => :event

  before_validation_on_create :set_plans

   TRANSLATE_PAYMENT_ERRORS = {
    507 => N_("Credit card number is invalid"),
    509 => N_("Credit card number is blocked"),
    510 => N_("Credit card is expired"),
    511 => N_("Missing card holder Name"),
    512 => N_("Missing or incorrect length of card verification number (cvv2)"),
    513 => N_("Missing government issued id number"),
    514 => N_("Missing card holder phone number"),
    515 => N_("Missing card holder email address"),
    517 => N_("Full name is invalid"),
    525 => N_("Daily volume limit exceeded"),
    540 => N_("Billing address - missing address"),
    541 => N_("Billing address - missing city name"),
    542 => N_("Billing address - missing zip code"),
    543 => N_("Billing address - missing or invalid state"),
    544 => N_("Billing address - missing or invalid country"),
    583 => N_("Weekly charge count limit reached for this credit card"),
    584 => N_("Weekly charge amount limit reached for this credit card"),
    585 => N_("Charge count limit reached for this credit card"),
    586 => N_("Charge amount limit reached for this credit card"),
    593 => N_("Monthly charge count limit reached for this credit card"),
    594 => N_("Monthly charge amount limit reached for this credit card"),
    597 => N_("Daily charge count limit reached for this credit card"),
    598 => N_("Daily charge amount limit reached for this credit card"),
    599 => N_("Declined by issuing bank")
  }

  def finalize_payment!(params)
    unless Netpay::HostedPage.success?(params[:replyCode])
      @payment_status_description = _(params[:replyDesc])
      raise PaymentError
    end
    self.paid_at = params[:trans_date]
    self.transaction_id = params[:trans_id]
    save!
    # update event plans
    self.event.emails_plan = emails_plan
    self.event.sms_plan = sms_plan
    self.event.prints_plan = prints_plan.to_i
    self.event.save!
    true
  end

  def pay!
    #the old way of paying. Kept for code reference
    raise ActiveRecord::RecordInvalid.new(self) unless valid?

    transaction_description = _("Eventify - payment for %{event_name}") % {:event_name => event.name}

    s = Netpay::SilentPost.new(NETPAY_MERCHANT_ID, self.id.to_s, NETPAY_SKIP_SSL)
    s.process(cc, expiration_month, expiration_year, name_on_card, amount, ccv2, email, user_ident, phone_number, transaction_description, "ILS")

    unless s.success?
      @payment_status_description = TRANSLATE_PAYMENT_ERRORS.member?(s.parsed_response[:Reply].to_i) ?
        _(s.parsed_response[:ReplyDesc]) : _("Payment failed")

      raise PaymentError
    end

    self.paid_at = Time.now.utc
    self.succeed_netpay_log_id = s.log_id
    save!
    # update event plans
    self.event.emails_plan = emails_plan
    self.event.sms_plan = sms_plan
    self.event.prints_plan = prints_plan.to_i
    self.event.save!
    true
  end

  def set_plans
    self.emails_plan_prev = event.emails_plan
    self.sms_plan_prev = event.sms_plan
    self.prints_plan_prev = event.prints_plan

    _, self.pay_sms        = upgrade_plan(:sms_plan, sms_plan.to_i, event.sms_plan)
    _, self.pay_prints     = upgrade_plan(:prints_plan, prints_plan.to_i, event.prints_plan)
    _, self.pay_emails     = upgrade_plan(:emails_plan, emails_plan.to_i, event.emails_plan)
  end

  def validate
    errors.add(:base, _("Please agree to the terms of use.")) unless self.is_agreed_to_terms?
    #logger.debug("NIV: #{self.amount} #{calculated_amount} #{payment_is_not_enough?}")
    errors.add(:base, _("Please choose a package that reflects your event")) if self.amount != calculated_amount || payment_is_not_enough?
  end

  def set_names_from_user
    self.email = user.email
    self.name_on_card = user.name
  end

  def payment_is_not_enough?
    p = event.payments.new
    p.calc_defaults

    (emails_plan < p.emails_plan) || (sms_plan < p.sms_plan) || (prints_plan.to_i < p.prints_plan)
  end

  def calc_defaults
    self.sms_plan, @extra_payment_sms       = upgrade_plan(:sms_plan, event.total_sms_count, event.sms_plan)
    self.prints_plan, @extra_payment_prints = upgrade_plan(:prints_plan, event.prints_ordered, event.prints_plan)
    self.emails_plan, extra_payment_emails  = upgrade_plan(:emails_plan, event.total_invitations_count, event.emails_plan)

    self.amount = @extra_payment_sms + @extra_payment_prints + extra_payment_emails
    self
  end

  def calculated_amount
    set_plans unless pay_sms || pay_prints || pay_emails
    total = pay_sms + pay_prints + pay_emails
    total <= 0 ? 0 : total
  end

  def upgrade?
    @upgrade ||= (event.payments.paid.count > 0)
  end

  def email_upgrade_price(to_count)
    _, price = upgrade_plan(:emails_plan, to_count, event.emails_plan)
    price < 0 ? 0 : price
  end

  def upgrade_plan(plan, new_count, old_count)
    #TODO: this needs to be modified when I make it possible to add a movie event after payment where maid to non movie events
    if plan == :emails_plan
      #plan = :premium_emails_plan if self.event.is_premium?
      new_plan, full_payment = Eventify.emails_plan(self.event.event_type, new_count)
      _, already_paid        = Eventify.emails_plan(self.event.event_type, old_count)
    else
      new_plan, full_payment = Eventify.send(plan, new_count)
      _, already_paid        = Eventify.send(plan, old_count)
    end
    [new_plan, full_payment - already_paid]
  end
end
