class PaymentsController < InheritedResources::Base
  before_filter :require_user
  belongs_to :event
  before_filter :verify_paid, :only => :update
  respond_to :js, :only => :create
  skip_before_filter :setup_localization, :only => [:edit, :update]
  before_filter      :setup_localization_skip_domain, :only => [:edit, :update]


  actions :new, :edit, :update, :create

  filter_parameter_logging :cc, :expiration_month, :expiration_year, :ccv2, :user_ident

  def new
    build_resource
    reload_payment
    new!
  end

  def edit
    resource.set_names_from_user
    payment_details = _("%{email_plan} %{emails} - %{email_price} ₪, %{sms_plan} %{sms} - %{sms_price} ₪") % {:email_plan => resource.emails_plan, :emails => _('Emails'), :email_price => resource.pay_emails.format_cents, :sms_plan => resource.sms_plan, :sms => _("SMS"), :sms_price => resource.pay_sms.format_cents}
    @payment_url = Netpay::HostedPage.new(resource, payment_details, update_event_payment_url(resource.event.id, resource.id), netpay_log_url).get_url
    render :json => {:payment_url => @payment_url}.to_json
  end

  def update
    unless Netpay::HostedPage.validate_response(params)
      raise ActiveRecord::RecordInvalid.new(resource)
    end
    begin
      resource.finalize_payment!(params)
      @redirect_url = get_path_to_back_page
    rescue PaymentError
      @error_msg = _("A problem occured: %{error_description}") % {:error_description => resource.payment_status_description || _("Payment failed")}
    end
    render :action => "update", :layout => false
    #  render :action => :edit
    #end
    #redirect_to_back_page
    #resource.load_payment_details(params[:payment])
    #
    #begin
    #  resource.pay!
    #  flash[:notice] = _("Paid successfully.")
    #  redirect_to_back_page
    #rescue ActiveRecord::RecordInvalid
    #  render :action => :edit
    #rescue PaymentError
    #  flash.now[:error] = _("A problem occured: %{error_description}") % {:error_description => resource.payment_status_description}
    #  render :action => :edit
    #end
  end

  def create
    build_resource
    resource.user_id = current_user.id
    unless resource.user.is_agreed_to_terms
      if params[:is_agree_to_terms] != "1"
        render :json => {:error => _("Please agree to the terms of use.")}.to_json
        return
      else
        resource.user.is_agreed_to_terms = true
        resource.user.save
      end
    end
    create! do |success, failure|
      success.js {
        redirect_to edit_event_payment_path(resource.event.id, resource.id)
      }
      failure.js {
        render :json => {:error => resource.errors.on(:base),:to_refresh => true}.to_json
      }
    end
  end

protected
  def verify_paid
    redirect_to get_path_to_back_page unless resource.paid_at.nil?
  end

  def get_path_to_back_page
    case params[:back]
    when "cancellations"
      edit_cancellation_url(resource.event_id, :locale => current_locale, :protocol => "http://")
    else # any or 'invitations'
      edit_invitation_url(resource.event_id, :locale => current_locale, :protocol => "http://")
    end
  end

  def begin_of_association_chain
    current_user
  end

  def ssl_redirect
    redirect_to(:protocol => "https://")  if Rails.env == "production" && !request.ssl?
  end

  def ssl_required
    return false if Rails.env == "production" && !request.ssl?
  end

  def setup_localization_skip_domain
    @disable_language_change = true
    setup_localization({})
  end

  def reload_payment
    resource.calc_defaults
    @invitations_count = resource.event.total_invitations_count
  end
end
